defmodule BrightWeb.SearchLive.UserSearchComponent do
  use BrightWeb, :live_component

  alias Bright.{CareerFields, SkillPanels, UserSearches, RecruitmentStockUsers}
  alias Bright.SearchForm.{UserSearch, SkillSearch}
  alias Bright.UserJobProfiles.UserJobProfile
  alias BrightWeb.SearchLive.SearchResultsComponent
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  import BrightWeb.TabComponents, only: [tab_footer: 1]

  @class [クラス1: 1, クラス2: 2, クラス3: 3]
  @level [見習い: "beginner", 平均: "normal", ベテラン: "skilled"]

  @impl true
  def mount(socket) do
    search = %UserSearch{skills: [%SkillSearch{}]}
    changeset = UserSearch.changeset(search, %{})

    career_fields =
      CareerFields.list_career_fields()
      |> Enum.map(&{&1.name_ja, &1.name_en})

    skill_panels =
      SkillPanels.list_skill_panel_with_career_field()
      |> Enum.group_by(& &1.career_field, &{&1.name, &1.id})
      |> Map.put(nil, [])

    socket
    |> assign(:user_search, search)
    |> assign(:career_fields, career_fields)
    |> assign(:skill_panels, skill_panels)
    |> assign(:class, @class)
    |> assign(:level, @level)
    |> assign(:search_results, [])
    |> assign(:skill_params, [])
    |> assign(:stock_user_ids, [])
    |> assign(:no_result, false)
    |> assign(:total_pages, 0)
    |> assign(:page, 1)
    |> assign_form(changeset)
    |> then(&{:ok, &1})
  end

  @impl true
  def update(assigns, socket), do: {:ok, assign(socket, assigns)}

  @impl true
  def handle_event(
        "validate",
        %{"user_search" => user_search_params, "_target" => target},
        socket
      ) do
    params =
      user_search_params
      |> reset_pj_end(target)
      |> reset_work_style(target)
      |> reset_skill_form_when_career_field_change(target)

    changeset =
      socket.assigns.user_search
      |> UserSearch.changeset(params)
      |> Map.put(:action, :validte)

    socket
    |> assign(:changeset, changeset)
    |> assign_form(changeset)
    |> then(&{:noreply, &1})
  end

  def handle_event("search", _params, %{assigns: %{changeset: %{changes: changes}}} = socket)
      when map_size(changes) == 0 do
    {:noreply, assign(socket, :search_results, [])}
  end

  def handle_event("search", _params, %{assigns: %{changeset: %{valid?: false}}} = socket) do
    {:noreply, socket}
  end

  def handle_event(
        "search",
        _params,
        %{assigns: %{changeset: %{changes: changes}, current_user: user}} = socket
      ) do
    {skills, search_params} = convert_changes_to_search_params(changes)

    case UserSearches.search_users_by_job_profile_and_skill_score(
           search_params,
           [user.id]
         ) do
      %{entries: []} ->
        socket
        |> assign(:search_results, [])
        |> assign(:skill_params, [])
        |> assign(:no_result, true)
        |> then(&{:noreply, &1})

      %{entries: users, total_pages: total_pages, page_number: page} ->
        socket
        |> assign(:search_results, users)
        |> assign(:total_pages, total_pages)
        |> assign(:page, page)
        |> assign(:skill_params, skills)
        |> assign(:stock_user_ids, RecruitmentStockUsers.list_stock_user_ids(user.id))
        |> assign(:no_result, false)
        |> then(&{:noreply, &1})
    end
  end

  def handle_event("search", _params, socket), do: {:noreply, socket}

  def handle_event(
        "previous_button_click",
        _params,
        %{assigns: %{page: page, changeset: changeset, current_user: user}} = socket
      ) do
    page = page - 1
    page = if page < 1, do: 1, else: page
    {_, search_params} = convert_changes_to_search_params(changeset.changes)

    %{entries: users} =
      UserSearches.search_users_by_job_profile_and_skill_score(search_params, [user.id], page)

    socket
    |> assign(:search_results, users)
    |> assign(:page, page)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "next_button_click",
        _params,
        %{
          assigns: %{
            page: page,
            total_pages: total_pages,
            changeset: changeset,
            current_user: user
          }
        } = socket
      ) do
    page = page + 1
    page = if page > total_pages, do: total_pages, else: page

    {_, search_params} = convert_changes_to_search_params(changeset.changes)

    %{entries: users} =
      UserSearches.search_users_by_job_profile_and_skill_score(search_params, [user.id], page)

    socket
    |> assign(:search_results, users)
    |> assign(:page, page)
    |> then(&{:noreply, &1})
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp disabled?(bool_or_string), do: to_string(bool_or_string) == "false"

  defp convert_changes_to_search_params(changes) do
    skills =
      Map.get(changes, :skills, [])
      |> Enum.map(& &1.changes)
      |> Enum.reject(&(Map.get(&1, :skill_panel) == nil))

    search_params = {
      Map.put(changes, :job_searching, true)
      |> Map.drop([:skills, :pj_start, :pj_end, :desired_income])
      |> Map.to_list(),
      Map.take(changes, [:pj_start, :pj_end, :desired_income]),
      skills
    }

    {skills, search_params}
  end

  # キャリアフィールドが変更されたら、それ以降の値はリセットされる
  defp reset_skill_form_when_career_field_change(params, [_, "skills", index, "career_field"]) do
    merge_skill_params(params, index, %{"class" => "", "level" => "", "skill_panel" => ""})
  end

  defp reset_skill_form_when_career_field_change(params, [_, "skills", index, "skill_panel"]) do
    merge_skill_params(params, index, %{"class" => "", "level" => ""})
  end

  defp reset_skill_form_when_career_field_change(params, [_, "skills", index, "class"]) do
    merge_skill_params(params, index, %{"level" => ""})
  end

  defp reset_skill_form_when_career_field_change(params, _target), do: params

  defp merge_skill_params(params, index, clear_params) do
    skills = Map.get(params, "skills")

    skill =
      Map.get(skills, index)
      |> Map.merge(clear_params)

    Map.put(params, "skills", Map.put(skills, index, skill))
  end

  # 勤務体系のチェックが外れるとそれ以降の入力がクリアされる
  defp reset_work_style(params, [_, "office_work"]),
    do:
      Map.merge(params, %{
        "office_pref" => "",
        "office_working_hours" => "",
        "office_work_holidays" => "false"
      })

  defp reset_work_style(params, [_, "remote_work"]),
    do: Map.merge(params, %{"remote_working_hours" => "", "remote_work_holidays" => "false"})

  defp reset_work_style(params, _target), do: params

  # undecidedがクリックされたら pj_endがクリアされ、pj_endを入力するとundecidedがクリアされる
  defp reset_pj_end(params, [_, "pj_end_undecided"]), do: Map.put(params, "pj_end", "")
  defp reset_pj_end(params, [_, "pj_end"]), do: Map.put(params, "pj_end_undecided", "false")
  defp reset_pj_end(params, _target), do: params
end
