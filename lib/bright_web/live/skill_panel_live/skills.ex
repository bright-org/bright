defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias BrightWeb.PathHelper

  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign_display_user(params)
     |> assign_skill_panel(params["skill_panel_id"], "panels")
     |> assign(:page_title, "スキルパネル")
     |> assign_page_sub_title()
     |> assign_edit_off()}
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
  def handle_event("edit", _params, socket) do
    socket.assigns.me
    |> if do
      {:noreply, socket |> assign_edit_on()}
    else
      {:noreply, socket}
    end
  end

  def handle_event("submit", _params, socket) do
    target_skill_scores =
      socket.assigns.skill_score_dict
      |> Map.values()
      |> Enum.filter(& &1.changed)

    {:ok, _} = SkillScores.update_skill_scores(socket.assigns.current_user, target_skill_scores)
    skill_class_score = SkillScores.get_skill_class_score!(socket.assigns.skill_class_score.id)

    {:noreply,
     socket
     |> assign_skill_classes()
     |> assign(skill_class_score: skill_class_score)
     |> assign_skill_score_dict()
     |> assign_counter()
     |> assign_edit_off()}
  end

  def handle_event("change", %{"score" => score, "skill_id" => skill_id, "row" => row}, socket) do
    score = String.to_atom(score)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)
    row = String.to_integer(row)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> assign(:focus_row, row)}
  end

  def handle_event("shortcut", %{"key" => key, "skill_id" => skill_id}, socket)
      when key in ~w(1 2 3) do
    score = Map.get(@shortcut_key_score, key)
    skill_score = Map.get(socket.assigns.skill_score_dict, skill_id)

    {:noreply,
     socket
     |> update_by_score_change(skill_score, score)
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowDown Enter) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.min([&1 + 1, socket.assigns.num_skills]))}
  end

  def handle_event("shortcut", %{"key" => key}, socket) when key in ~w(ArrowUp) do
    {:noreply,
     socket
     |> update(:focus_row, &Enum.max([1, &1 - 1]))}
  end

  def handle_event("shortcut", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "click_on_related_user_card_menu",
        %{"encrypt_user_name" => encrypt_user_name},
        socket
      )
      when encrypt_user_name != "" do
    {:noreply,
     push_redirect(socket, to: ~p"/panels/#{socket.assigns.skill_panel}/anon/#{encrypt_user_name}")}
  end

  def handle_event("click_on_related_user_card_menu", params, socket) do
    # TODO: チームメンバー以外の対応時に匿名に注意すること
    user = Bright.Accounts.get_user_by_name(params["name"])

    # 参照可能なユーザーかどうかの判定は遷移先で行うので必要ない
    {:noreply, push_redirect(socket, to: ~p"/panels/#{socket.assigns.skill_panel}/#{user.name}")}
  end

  def handle_event("clear_display_user", _params, socket) do
    %{current_user: current_user, skill_panel: skill_panel} = socket.assigns
    move_to = get_path_to_switch_me("panels", current_user, skill_panel)

    {:noreply, push_redirect(socket, to: move_to)}
  end

  defp apply_action(socket, :show, _params), do: socket

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

  defp assign_edit_off(socket) do
    socket
    |> assign(edit: false, focus_row: nil)
  end

  defp assign_edit_on(socket) do
    socket
    |> assign(edit: true, focus_row: 1)
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
    skill = socket.assigns.skill
    skill_score = Map.get(socket.assigns.skill_score_dict, skill.id)

    if skill_score.reference_read do
      socket
    else
      {:ok, skill_score} =
        SkillScores.update_skill_score(skill_score, %{"reference_read" => true})

      socket
      |> update(:skill_score_dict, &Map.put(&1, skill.id, skill_score))
    end
  end

  defp assign_skill_exam(socket) do
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: socket.assigns.skill.id)

    socket
    |> assign(skill_exam: skill_exam)
  end

  defp update_exam_progress_wip(socket) do
    skill = socket.assigns.skill
    skill_score = Map.get(socket.assigns.skill_score_dict, skill.id)

    if skill_score.exam_progress in [:wip, :done] do
      socket
    else
      {:ok, skill_score} = SkillScores.update_skill_score(skill_score, %{"exam_progress" => :wip})

      socket
      |> update(:skill_score_dict, &Map.put(&1, skill.id, skill_score))
    end
  end

  defp update_by_score_change(socket, skill_score, score) do
    # 習得率の変動反映
    current_score = skill_score.score

    counter =
      socket.assigns.counter
      |> Map.update!(current_score, &(&1 - 1))
      |> Map.update!(score, &(&1 + 1))

    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    socket
    |> assign(
      counter: counter,
      skill_score_dict: skill_score_dict
    )
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
end
