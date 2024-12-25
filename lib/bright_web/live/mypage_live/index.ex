defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view

  import BrightWeb.MypageLive.EngineerPage
  import BrightWeb.MypageLive.MedicalPage

  alias Bright.SkillUnits
  alias Bright.SkillEvidences
  alias Bright.SkillScores
  alias Bright.Teams
  alias Bright.CareerFields
  alias BrightWeb.DisplayUserHelper

  def render(%{type: :medical} = assigns) do
    ~H"""
    <.medical assigns={assigns} />
    """
  end

  def render(assigns) do
    ~H"""
    <.engineer assigns={assigns} />
    """
  end

  def mount(params, _session, socket) do
    socket
    |> DisplayUserHelper.assign_display_user(params)
    |> assign(:type, socket.assigns.current_user.type)
    |> assign(:page_title, "マイページ")
    |> then(&{:ok, &1})
  end

  def handle_params(params, _url, socket) do
    {:noreply,
     socket
     |> assign_career_field(params["q"])
     |> assign_skillset_gem()
     |> assign_recent_level_up_skill_classes()
     |> assign_related_user_ids()
     |> assign_recent_others_skill_evidences()
     |> apply_action(socket.assigns.live_action, params)}
  end

  def handle_event("clear_display_user", _params, socket) do
    {:noreply, push_navigate(socket, to: ~p"/mypage")}
  end

  def handle_event("edit_skill_evidence", %{"id" => id}, socket) do
    %{current_user: current_user} = socket.assigns
    skill_evidence = SkillEvidences.get_skill_evidence!(id)
    skill = SkillUnits.get_skill!(skill_evidence.skill_id)

    # モーダルを開き、表示内容を選択した学習メモで初期化する
    send_update(BrightWeb.ModalComponent,
      id: "skill-evidence-modal",
      open: true,
      on_open: fn ->
        send_update(BrightWeb.SkillPanelLive.SkillEvidenceComponent,
          id: "skill-evidence",
          reset: true,
          skill_evidence: skill_evidence,
          skill: skill,
          user: current_user,
          me: current_user.id == skill_evidence.user_id
        )
      end
    )

    {:noreply, socket}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "マイページ")
    |> assign(:search, false)
  end

  defp apply_action(socket, :search, _params) do
    socket
    |> assign(:page_title, "スキル検索／スカウト")
    |> assign(:search, true)
  end

  defp apply_action(socket, :free_trial, params) do
    plan = Map.get(params, "plan", "hr_plan")

    socket
    |> assign(:page_title, "無料トライアル")
    |> assign(:plan, plan)
    |> assign(:search, false)
  end

  defp assign_career_field(socket, nil) do
    assign(socket, :career_field, nil)
  end

  defp assign_career_field(socket, name_en) do
    career_field = CareerFields.get_career_field_by!(name_en: name_en)
    assign(socket, :career_field, career_field)
  end

  defp assign_skillset_gem(socket) do
    skillset_gem =
      SkillScores.get_skillset_gem(socket.assigns.display_user.id)
      |> Enum.sort_by(& &1.position, :asc)
      |> Enum.map(&[&1.key, &1.name, floor(&1.percentage)])
      |> Enum.zip_reduce([], &(&2 ++ [&1]))
      |> then(fn
        [] ->
          nil

        [keys, names, percentags] ->
          links = Enum.map(keys, &"?q=#{&1}")
          %{labels: names, data: percentags, links: links}
      end)

    assign(socket, :skillset_gem, skillset_gem)
  end

  defp assign_recent_level_up_skill_classes(socket) do
    %{display_user: display_user} = socket.assigns

    recent_level_up_skill_class_scores =
      SkillScores.list_recent_level_up_skill_class_scores(display_user)

    assign(socket, :recent_level_up_skill_class_scores, recent_level_up_skill_class_scores)
  end

  defp assign_related_user_ids(socket) do
    %{current_user: user} = socket.assigns
    assign(socket, :related_user_ids, Teams.list_user_ids_related_team_by_user(user))
  end

  defp assign_recent_others_skill_evidences(%{assigns: %{me: true}} = socket) do
    %{related_user_ids: related_user_ids} = socket.assigns

    # 必要に応じてstream化のこと
    recent_others_skill_evidences =
      SkillEvidences.list_recent_skill_evidences(related_user_ids)
      |> Bright.Repo.preload(skill_evidence_posts: [user: [:user_profile]])
      |> Enum.filter(fn skill_evidence ->
        # メモ所有者本人の投稿があることを前提とする
        Enum.find(skill_evidence.skill_evidence_posts, &(&1.user_id == skill_evidence.user_id))
      end)

    assign(socket, :recent_others_skill_evidences, recent_others_skill_evidences)
  end

  defp assign_recent_others_skill_evidences(socket) do
    # 他者表示のときは使用しない
    assign(socket, :recent_others_skill_evidences, nil)
  end
end
