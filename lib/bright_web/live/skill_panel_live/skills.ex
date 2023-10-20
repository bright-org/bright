defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillsComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper
  import BrightWeb.GuideMessageComponents

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias Bright.UserJobProfiles
  alias BrightWeb.PathHelper

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign_display_user(params)
     |> assign_skill_panel(params["skill_panel_id"], "panels")
     |> assign(:page_title, "スキルパネル")
     |> assign_page_sub_title()}
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}}} = socket) do
    # TODO: データ取得方法検討／LiveVIewコンポーネント化検討
    {:noreply,
     socket
     |> assign_path(url)
     |> assign_skill_classes()
     |> assign_skill_class_and_score(params["class"])
     |> create_skill_class_score_if_not_existing()
     |> assign_skill_score_dict()
     |> assign_counter()
     |> apply_action(socket.assigns.live_action, params)
     |> touch_user_skill_panel()}
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket),
    do: {:noreply, socket}

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    skill_panel = socket.assigns.skill_panel
    # TODO: 参照可能なユーザーかどうかの判定を行うこと
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

  defp apply_action(socket, :show, params) do
    socket
    |> assign(:init_team_id, params["team"])
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
  defp put_flash_first_skills_edit(socket) do
    %{skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)

    (skill_class.class == 1 && Enum.all?(skill_scores, &(&1.score == :low)))
    |> if do
      update(socket, :flash, &Map.put(&1, "first_skills_edit", true))
    else
      socket
    end
  end

  defp user_job_searching?(user) do
    user.id
    |> UserJobProfiles.get_user_job_profile_by_user_id!()
    |> Map.get(:job_searching)
  end
end
