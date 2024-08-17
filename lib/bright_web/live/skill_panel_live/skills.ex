defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper
  import BrightWeb.GuideMessageComponents

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillScores.SkillScore
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias Bright.UserJobProfiles
  alias Bright.UserSkillPanels
  alias BrightWeb.PathHelper
  alias BrightWeb.ProfileComponents
  alias BrightWeb.GuideMessageComponents
  alias BrightWeb.SnsComponents
  alias BrightWeb.Share.Helper, as: ShareHelper
  alias BrightWeb.QrCodeComponents
  alias BrightWeb.SkillPanelLive.GrowthShareModalComponent
  alias BrightWeb.SkillPanelLive.SkillShareModalComponent

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign_display_user(params)
    |> assign_skill_panel(params["skill_panel_id"])
    |> assign(:select_label, "now")
    |> assign(:select_label_compared_user, nil)
    |> assign(:compared_user, nil)
    |> assign(:page_title, "スキルパネル")
    |> assign(:view, :card)
    |> assign(init_team_id: nil, init_timeline: nil)
    |> assign(:selected_unit, nil)
    |> push_event("scroll_to_unit", %{})
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}}} = socket) do
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_classes()
     # TODO テスト用
     |> assign(:skill_share_open, false)
     # TODO テスト用
     |> assign(
       :skill_share_data,
       Bright.SkillScores.get_level_count_from_skill_panel_id(socket.assigns.skill_panel.id)
       |> Map.merge(%{name: socket.assigns.skill_panel.name})
     )
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> apply_action(socket.assigns.live_action, params)
     |> ShareHelper.assign_share_graph_url()
     |> touch_user_skill_panel()}
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket),
    do: {:noreply, socket}

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    skill_panel = socket.assigns.skill_panel

    {user, anonymous} =
      get_user_from_name_or_name_encrypted(params["name"], params["encrypt_user_name"])

    get_path_to_switch_display_user("panels", user, skill_panel, anonymous)
    |> case do
      {:ok, path} ->
        {:noreply, push_redirect(socket, to: path)}

      :error ->
        {:noreply,
         socket
         |> put_flash(:error, "選択された対象者がスキルパネルを保有していないため、対象者を表示できません")}
    end
  end

  def handle_event("clear_display_user", _params, socket) do
    %{current_user: current_user, skill_panel: skill_panel} = socket.assigns
    move_to = get_path_to_switch_me("panels", current_user, skill_panel)

    {:noreply, push_redirect(socket, to: move_to)}
  end

  def handle_event("click_skill_star_button", _params, %{assigns: assigns} = socket) do
    is_star = !assigns.is_star

    socket =
      socket
      |> assign(:is_star, is_star)

    UserSkillPanels.set_is_star(assigns.display_user, assigns.skill_panel, is_star)
    {:noreply, socket}
  end

  def handle_event("og_image_data_click", %{"value" => value}, socket) do
    {:noreply, assign_og_image_data(socket, value)}
  end

  def handle_event("sns_up_click", _params, socket) do
    upload_ogp_data(socket.assigns)
    {:noreply, socket}
  end

  def handle_event("change_view", %{"view" => view}, socket) do
    socket
    |> assign(:view, String.to_atom(view))
    |> push_event("scroll_to_unit", %{})
    |> then(&{:noreply, &1})
  end

  def handle_event("update_score", %{"score_id" => id, "score" => score} = params, socket) do
    skill_class_score = socket.assigns.skill_class_score
    prev_skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)

    SkillScores.get_skill_score!(id)
    |> Map.put(:score, String.to_atom(score))
    |> then(&[&1])
    |> SkillScores.insert_or_update_skill_scores(socket.assigns.current_user)

    send_update(BrightWeb.OgpComponent, id: "ogp")

    open_growth_share(prev_skill_class_score)
    assign_renew(socket, params["class"])
  end

  def handle_event("update_score", %{"skill_id" => id, "score" => score} = params, socket) do
    [
      %SkillScore{
        skill_id: id,
        score: String.to_atom(score),
        user_id: socket.assigns.current_user.id
      }
    ]
    |> SkillScores.insert_or_update_skill_scores(socket.assigns.current_user)

    assign_renew(socket, params["class"])
  end

  defp assign_renew(socket, class) do
    socket
    |> assign_skill_class_and_score(class)
    |> assign_skill_score_dict()
    |> assign_counter()
    |> then(&{:noreply, &1})
  end

  defp apply_action(socket, :show, params) do
    socket
    |> assign(:init_team_id, params["team"])
    |> assign(:init_timeline, params["timeline"])
    |> put_flash_first_skills_edit()
  end

  defp apply_action(socket, :edit, _params), do: socket

  defp apply_action(socket, :show_evidences, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_evidence()
    |> create_skill_evidence_if_not_existing()
  end

  defp apply_action(socket, :show_reference, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_reference()
    |> update_reference_read()
  end

  defp apply_action(socket, :show_exam, params) do
    socket
    |> assign_skill(params["skill_id"])
    |> assign_skill_exam()
    |> update_exam_progress_wip()
  end

  defp assign_skill(socket, skill_id) do
    skill = SkillUnits.get_skill!(skill_id)

    socket |> assign(skill: skill)
  end

  defp assign_skill_evidence(socket) do
    skill_evidence =
      SkillEvidences.get_skill_evidence_by(
        user_id: socket.assigns.display_user.id,
        skill_id: socket.assigns.skill.id
      )

    socket
    |> assign(skill_evidence: skill_evidence)
  end

  defp assign_skill_reference(socket) do
    skill_reference = SkillReferences.get_skill_reference_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_reference: skill_reference)
  end

  defp update_reference_read(socket) do
    %{current_user: user, skill: skill} = socket.assigns

    {:ok, skill_score} = SkillScores.make_skill_score_reference_read(user, skill)
    update(socket, :skill_score_dict, &Map.put(&1, skill.id, skill_score))
  end

  defp assign_skill_exam(socket) do
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_exam: skill_exam)
  end

  defp update_exam_progress_wip(socket) do
    %{current_user: user, skill: skill, skill_score_dict: skill_score_dict} = socket.assigns
    skill_score = Map.get(skill_score_dict, skill.id)

    (skill_score && skill_score.exam_progress in [:wip, :done])
    |> if do
      socket
    else
      {:ok, skill_score} = SkillScores.make_skill_score_exam_progress(user, skill, :wip)
      update(socket, :skill_score_dict, &Map.put(&1, skill.id, skill_score))
    end
  end

  defp create_skill_evidence_if_not_existing(%{assigns: %{skill_evidence: nil}} = socket) do
    {:ok, skill_evidence} =
      SkillEvidences.create_skill_evidence(%{
        user_id: socket.assigns.display_user.id,
        skill_id: socket.assigns.skill.id,
        progress: :wip,
        skill_evidence_posts: []
      })

    socket
    |> assign(skill_evidence: skill_evidence)
  end

  defp create_skill_evidence_if_not_existing(socket), do: socket

  # 初回入力時のみメッセージを表示
  # 初回入力: スキルクラスがclass: 1でスキルスコアがない状態とする
  # メッセージ表示にはflashを利用している
  defp put_flash_first_skills_edit(%{assigns: %{me: true}} = socket) do
    %{skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)

    (skill_class.class == 1 && Enum.all?(skill_scores, &(&1.id == nil)))
    |> if do
      put_flash(socket, :first_skills_edit, true)
    else
      socket
    end
  end

  defp put_flash_first_skills_edit(socket), do: socket

  defp open_growth_share(skill_class_score) do
    prev_level = skill_class_score.level
    prev_percentage = skill_class_score.percentage

    skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
    new_level = skill_class_score.level
    new_percentage = skill_class_score.percentage

    if prev_level != new_level && prev_percentage < new_percentage do
      send_update(GrowthShareModalComponent,
        id: "growth_share",
        open: true,
        user_id: skill_class_score.user_id,
        skill_class_id: skill_class_score.skill_class_id
      )
    end
  end
end
