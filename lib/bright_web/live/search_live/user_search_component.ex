defmodule BrightWeb.SearchLive.UserSearchComponent do
  use BrightWeb, :live_component

  alias Bright.{CareerFields, SkillPanels, UserSearches}
  alias Bright.SearchForm.{UserSearch, SkillSearch}
  alias Bright.UserJobProfiles.UserJobProfile
  alias BrightWeb.SearchLive.SearchResultComponent
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  @class [クラス1: 1, クラス2: 2, クラス3: 3]
  @level [見習い: "beginner", 平均: "normal", ベテラン: "skilled"]

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <.form
        for={@form}
        id="user_search_form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="search"
      >
      <div class="border-b border-brightGray-200 flex flex-wrap items-center">
        <div class="flex items-center w-fit">
          <label class="flex items-center py-4">
            <span class="w-24">PJ期間</span>
            <BrightCore.input
              field={@form[:pj_start]}
              input_class="border border-brightGray-200 px-2 py-1  rounded w-30"
              type="date"
              size="20"
            />
            <span class="mx-1">～</span>
            <BrightCore.input
              field={@form[:pj_end]}
              input_class="border border-brightGray-200 px-2 py-1  rounded w-30"
              type="date"
              size="20"
            />
          </label>

          <label class="flex items-center ml-2">
          <BrightCore.input
                field={@form[:pj_end_undecided]}
                input_class="border border-brightGray-200 rounded"
                label_class="ml-1 text-xs"
                type="checkbox"
                label="終了日未定"
              />
          </label>
        </div>

        <div class="ml-auto w-fit">
          <label class="flex items-center py-4">
            <span class="w-24">希望年収<span class="block text-xs">（一人当たり）</span></span>
            <BrightCore.input
              field={@form[:desired_income]}
              input_class="border border-brightGray-200 px-2 py-1 rounded w-40"
              size="20"
              type="number"
              after_label="万円以下"
            />
          </label>
        </div>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap py-4 w-full">
        <span class="w-32">求職種類</span>
        <div class="-ml-8">
          <div class="flex items-center">
            <BrightCore.input
              field={@form[:wish_employed]}
              label_class="w-16 text-left"
              type="checkbox"
              label="就職"
            />
            <BrightCore.input
              field={@form[:wish_change_job]}
              label_class="w-16 text-left"
              type="checkbox"
              label="転職"
            />
            <BrightCore.input
              field={@form[:wish_side_job]}
              label_class="w-16 text-left"
              type="checkbox"
              label="副業"
            />
            <BrightCore.input
              field={@form[:wish_freelance]}
              label_class="w-24 text-left"
              type="checkbox"
              label="フリーランス"
            />
          </div>
        </div>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap py-4 w-full">
        <span class="py-1 w-32">勤務体系</span>
        <div class="-ml-8">
          <div class="flex items-center">
            <BrightCore.input
              field={@form[:office_work]}
              label_class="w-16 text-left"
              type="checkbox"
              label="出勤"
            />
            <BrightCore.input
              field={@form[:office_pref]}
              input_class="w-36"
              disabled={disabled?(@form[:office_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :office_pref)}
              prompt="希望勤務地"
            />
            <BrightCore.input
              field={@form[:office_working_hours]}
              input_class="w-36"
              disabled={disabled?(@form[:office_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :office_working_hours)}
              prompt="希望勤務時間"
            />
            <BrightCore.input
              field={@form[:office_work_holidays]}
              container_class="ml-4"
              disabled={disabled?(@form[:office_work].value)}
              type="checkbox"
              label_class={if disabled?(@form[:office_work].value), do: "opacity-50"}
              label="土日祝の稼働も含む"
            />
          </div>

          <div class="flex items-center mt-2">
            <BrightCore.input
              field={@form[:remote_work]}
              label_class="w-16 text-left"
              type="checkbox"
              label="リモート"
            />
            <BrightCore.input
              field={@form[:remote_working_hours]}
              input_class="w-36"
              disabled={disabled?(@form[:remote_work].value)}
              type="select"
              options={Ecto.Enum.mappings(UserJobProfile, :remote_working_hours)}
              prompt="希望勤務時間"
            />
            <BrightCore.input
              field={@form[:remote_work_holidays]}
              container_class="ml-4"
              disabled={disabled?(@form[:remote_work].value)}
              type="checkbox"
              label_class={if disabled?(@form[:remote_work].value), do: "opacity-50"}
              label="土日祝の稼働も含む"
            />
          </div>
        </div>
      </div>

      <div class="flex mt-4" id="skill_section">
        <span class="mt-2 w-24">スキル</span>
        <div class="-ml-5">
        <.inputs_for :let={sk} field={@form[:skills]} >
          <input type="hidden" name="user_search[skills_sort][]" value={sk.index}>
          <div class="flex items-center mb-4">
            <label class="cursor-pointer" :if={sk.index > 0}>
              <input
                type="checkbox"
                name="user_search[skills_drop][]"
                value={sk.index}
                class="hidden"
              />
              <i class="delete_skill_conditions bg-attention-600 block border border-attention-600 cursor-pointer h-4 indent-40 -ml-5 mr-1 overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white hover:opacity-50">スキル削除</i>
            </label>

            <BrightCore.input
              field={sk[:career_field]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-46 text-md"
              type="select"
              options={@career_fields}
              prompt="キャリアフィールド"
            />
            <BrightCore.input
              field={sk[:skill_panel]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-44"
              type="select"
              options={Map.get(@skill_panels, sk[:career_field].value)}
              disabled={is_nil(sk[:career_field].value)}
              prompt="スキルパネル"
            />
            <BrightCore.input
              field={sk[:class]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-26"
              type="select"
              options={@class}
              disabled={sk[:skill_panel].value in ["", nil]}
              prompt="クラス"
            />
            <BrightCore.input
              field={sk[:level]}
              input_class="border border-brightGray-200 mr-2 px-2 py-1 rounded w-26"
              type="select"
              options={@level}
              disabled={sk[:class].value in ["", nil]}
              prompt="レベル"
            />
            <a
              class="bg-white border border-solid border-brightGray-900 cursor-pointer font-bold ml-6 px-2 py-1 rounded select-none text-center text-brightGray-900 w-44 hover:opacity-50"
            >
              スキル詳細も設定
            </a>
          </div>
        </.inputs_for>
        </div>
      </div>
      <label class="block cursor-pointer" :if={Enum.count(@form[:skills].value) < 3}>
        <input type="checkbox" name="user_search[skills_sort][]" class="hidden" />
        <i id="set_skill_conditions" class="bg-brightGreen-900 block border border-brightGreen-900 cursor-pointer h-4 indent-40 mx-auto overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white after:top-1/2 after:left-1/2 after:-ml-1 after:-mt-px after:content-[''] after:block after:absolute after:w-2 after:h-0.5 after:bg-white after:rotate-90 hover:opacity-50">追加</i>
      </label>

      <div class="flex mt-16 mx-auto w-fit">
        <BrightCore.button phx-disable-with="Searching...">検索する</BrightCore.button>
      </div>
      </.form>
      <.live_component
        id="user_search_result"
        module={SearchResultComponent}
        current_user={@current_user}
        result={@search_results}
        skill_params={@skill_params}
      />
    </li>
    """
  end

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

  def handle_event("search", _params, %{assigns: %{changeset: %{changes: changes}}} = socket) do
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

    users =
      UserSearches.search_users_by_job_profile_and_skill_score(
        search_params,
        [socket.assigns.current_user.id]
      )

    socket
    |> assign(:search_results, users)
    |> assign(:skill_params, skills)
    |> then(&{:noreply, &1})
  end

  def handle_event("search", _params, socket), do: {:noreply, socket}

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp disabled?(bool_or_string), do: to_string(bool_or_string) == "false"

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
