defmodule BrightWeb.OnboardingLive.SkillInputs do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents
  import BrightWeb.SkillPanelLive.SkillCardComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper
  import BrightWeb.GuideMessageComponents
  import BrightWeb.SkillPanelLive.SkillPanelComponents, only: [no_skill_panel: 1]

  alias Bright.SkillPanels
  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillScores.SkillScore
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias BrightWeb.PathHelper
  alias BrightWeb.SkillPanelLive.GrowthShareModalComponent
  alias BrightWeb.Share.Helper, as: ShareHelper
  alias BrightWeb.SkillPanelLive.SkillShareModalComponent
  alias Bright.Utils.Aes.Aes128

  @class_color %{
    1 => "from-[#76D3B9] to-[#4857AD]",
    2 => "from-[#4857AD] to-[#AE959A]",
    3 => "from-[#AE959A] to-[#F2E994]"
  }

  @impl true
  def mount(params, _session, socket) do
    skill_panel_params =
      %{user_id: socket.assigns.current_user.id, skill_panel_id: params["skill_panel_id"]}

    socket
    |> assign_display_user(params)
    |> assign_skill_panel(skill_panel_params)
    |> assign(:return_to, "")
    |> assign(:select_label, "now")
    |> assign(:select_label_compared_user, nil)
    |> assign(:compared_user, nil)
    |> assign(:page_title, "スキルパネル")
    |> assign(:selected_unit, nil)
    |> assign(:gem_labels, [])
    |> assign(:gem_values, nil)
    |> assign(:class_color, @class_color)
    |> assign(:skill_share_open, false)
    |> push_event("scroll_to_unit", %{})
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}}} = socket) do
    socket
    |> assign_path(url)
    |> assign_return_to(params, url)
    |> assign_skill_classes()
    |> assign_skill_share_data()
    |> assign_skill_class_and_score(params["class"])
    |> create_skill_class_score_if_not_existing()
    |> assign_skill_score_dict()
    |> assign_skill_units()
    |> assign_counter()
    |> assign_gem_data()
    |> assign_links()
    |> apply_action(socket.assigns.live_action, params)
    |> ShareHelper.assign_share_graph_url()
    |> assign(encode_share_ogp: Aes128.encrypt("#{socket.assigns.skill_panel.id}},ogp"))
    |> touch_user_skill_panel()
    |> then(&{:noreply, &1})
  end

  def handle_params(_params, _url, %{assigns: %{skill_panel: nil}} = socket) do
    {:noreply, socket}
  end

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

  defp apply_action(socket, _, _params), do: put_flash_first_skills_edit(socket)

  @impl true
  def handle_event("click_on_related_user_card_menu", params, socket) do
    skill_panel = socket.assigns.skill_panel

    {user, anonymous} =
      get_user_from_name_or_name_encrypted(params["name"], params["encrypt_user_name"])

    get_path_to_switch_display_user("more_skills", user, skill_panel, anonymous)
    |> case do
      {:ok, path} ->
        {:noreply, push_redirect(socket, to: path)}

      :error ->
        {:noreply, put_flash(socket, :error, "選択された対象者がスキルパネルを保有していないため、対象者を表示できません")}
    end
  end

  def handle_event("og_image_data_click", %{"value" => value}, socket) do
    {:noreply, assign_og_image_data(socket, value)}
  end

  def handle_event("skill_shara_og_image_data_click", %{"value" => value}, socket) do
    {:noreply, assign_og_image_data(socket, value, :skill_shara_og_image_data)}
  end

  def handle_event("sns_up_click", _params, socket) do
    upload_ogp_data(socket.assigns)
    {:noreply, socket}
  end

  def handle_event("skill_sns_up_click", _params, socket) do
    upload_ogp_data(socket.assigns, :skill_shara_og_image_data)
    {:noreply, socket}
  end

  def handle_event("update_score", _params, %{assigns: %{me: false}} = socket) do
    {:noreply, socket}
  end

  def handle_event("update_score", %{"score_id" => id, "score" => score} = params, socket) do
    prev_skill_class_score = socket.assigns.skill_class_score

    prev_skill_share_data =
      SkillScores.get_level_count_from_skill_panel_id(
        socket.assigns.skill_panel.id,
        socket.assigns.skill_class.class
      )

    SkillScores.get_skill_score!(id)
    |> Map.put(:score, String.to_atom(score))
    |> then(&[&1])
    |> SkillScores.insert_or_update_skill_scores(socket.assigns.current_user)

    send_update(BrightWeb.OgpComponent, id: "ogp")

    open_growth_share(prev_skill_class_score, prev_skill_share_data)

    socket
    |> assign_renew(params["class"])
    |> assign_gem_data()
    |> then(&{:noreply, &1})
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

    {:noreply, assign_renew(socket, params["class"])}
  end

  def handle_event("scroll_to_unit", _params, socket) do
    {:noreply, push_event(socket, "scroll_to_unit", %{})}
  end

  defp update_reference_read(socket) do
    %{current_user: user, skill: skill} = socket.assigns

    {:ok, skill_score} = SkillScores.make_skill_score_reference_read(user, skill)
    update(socket, :skill_score_dict, &Map.put(&1, skill.id, skill_score))
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

  defp assign_gem_data(socket) do
    %{skill_units: skill_units, skill_score_dict: skill_score_dict} = socket.assigns

    {gem_labels, gem_values} =
      Enum.reduce(skill_units, {[], []}, fn skill_unit, {labels, values} ->
        percentage = get_percentage_in_skill_unit(skill_unit, skill_score_dict)
        {labels ++ [skill_unit.name], values ++ [percentage]}
      end)

    assign(socket, gem_labels: gem_labels, gem_values: gem_values)
  end

  defp assign_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(skill_units: [skill_categories: [:skills]])
      |> Map.get(:skill_units)

    assign(socket, :skill_units, skill_units)
  end

  defp assign_renew(socket, class) do
    socket
    |> assign_skill_class_and_score(class)
    |> assign_skill_score_dict()
    |> assign_counter()
  end

  defp assign_skill(socket, skill_id) do
    assign(socket, skill: SkillUnits.get_skill!(skill_id))
  end

  defp assign_skill_evidence(socket) do
    skill_evidence =
      SkillEvidences.get_skill_evidence_by(
        user_id: socket.assigns.display_user.id,
        skill_id: socket.assigns.skill.id
      )

    assign(socket, skill_evidence: skill_evidence)
  end

  defp assign_skill_reference(socket) do
    skill_reference = SkillReferences.get_skill_reference_by!(skill_id: socket.assigns.skill.id)

    assign(socket, skill_reference: skill_reference)
  end

  defp assign_skill_exam(socket) do
    skill_exam = SkillExams.get_skill_exam_by!(skill_id: socket.assigns.skill.id)

    assign(socket, skill_exam: skill_exam)
  end

  defp assign_skill_share_data(%{assigns: assigns} = socket) do
    skill_share_data =
      SkillScores.get_level_count_from_skill_panel_id(assigns.skill_panel.id)
      |> Map.merge(%{name: assigns.skill_panel.name})

    assign(socket, :skill_share_data, skill_share_data)
  end

  defp assign_return_to(socket, params, url) do
    # パンくずから一つ前に戻った時のスクロール先設定
    current_path = URI.parse(url).path |> Path.split() |> Enum.at(1) |> String.replace("/", "")
    id = params["skill_panel_id"]

    career_field =
      Map.get(
        params,
        "career_field",
        SkillPanels.get_skill_panel_with_career_fields!(id)
        |> Map.get(:career_fields, [%{name_en: "engineer"}])
        |> List.first()
        |> Map.get(:name_en)
      )

    assign(
      socket,
      :return_to,
      "/#{current_path}?panel=#{id}&career_field=#{career_field}"
    )
  end

  def assign_links(%{assigns: assigns} = socket) do
    1..length(assigns.gem_labels)
    |> Enum.map(fn x -> "#unit-" <> "#{x}" end)
    |> then(&assign(socket, :links, &1))
  end

  defp get_percentage_in_skill_unit(skill_unit, skill_score_dict) do
    skills = skill_unit.skill_categories |> Enum.flat_map(& &1.skills)
    size = Enum.count(skills)

    if size == 0 do
      0
    else
      num_high_skills = Enum.count(skills, &(Map.get(skill_score_dict, &1.id).score == :high))
      floor(num_high_skills / size * 100)
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

    assign(socket, skill_evidence: skill_evidence)
  end

  defp create_skill_evidence_if_not_existing(socket), do: socket

  # 初回入力時のみメッセージを表示
  # 初回入力: スキルクラスがclass: 1でスキルスコアがない状態とする
  # メッセージ表示にはSkillShareModalComponentを利用している
  defp put_flash_first_skills_edit(%{assigns: %{me: true}} = socket) do
    %{skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)

    (skill_class.class == 1 && Enum.all?(skill_scores, &(&1.id == nil)))
    |> if do
      assign(socket, :skill_share_open, true)
    else
      socket
    end
  end

  defp put_flash_first_skills_edit(socket), do: socket

  defp open_growth_share(skill_class_score, prev_skill_share_data) do
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
        skill_class_id: skill_class_score.skill_class_id,
        new_level: new_level,
        prev_level: prev_level,
        prev_skill_share_data: prev_skill_share_data
      )
    end
  end
end
