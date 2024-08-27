defmodule BrightWeb.SkillPanelLive.Skills do
  use BrightWeb, :live_view

  import BrightWeb.BrightModalComponents

  import BrightWeb.SkillPanelLive.SkillPanelComponents,
    only: [profile_skill_class_level: 1, score_mark_class: 2, no_skill_panel: 1]

  import BrightWeb.SkillPanelLive.SkillCardComponents
  import BrightWeb.SkillPanelLive.SkillPanelHelper
  import BrightWeb.DisplayUserHelper
  import BrightWeb.GuideMessageComponents
  import BrightWeb.ChartComponents, only: [skill_gem: 1]

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.SkillScores.SkillScore
  alias Bright.SkillEvidences
  alias Bright.SkillReferences
  alias Bright.SkillExams
  alias BrightWeb.PathHelper
  alias BrightWeb.SnsComponents
  alias BrightWeb.Share.Helper, as: ShareHelper
  alias BrightWeb.QrCodeComponents
  alias BrightWeb.SkillPanelLive.GrowthShareModalComponent
  alias BrightWeb.SkillPanelLive.SkillShareModalComponent
  alias Bright.Utils.Aes.Aes128

  # キーボード入力 1,2,3 と対応するスコア
  @shortcut_key_score %{
    "1" => :high,
    "2" => :middle,
    "3" => :low
  }

  # 入力時間目安表示のための１スキルあたりの時間(分): 約20秒
  @minute_per_skill 0.33

  # スコアと対応するHTML class属性
  @score_mark_class %{
    "high" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-4 before:w-4 before:rounded-full before:bg-brightGray-300 before:block peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]",
    "middle" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:h-0 before:w-0 before:border-solid before:border-t-0 before:border-r-8 before:border-l-8 before:border-transparent before:border-b-[14px] before:border-b-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:border-b-white hover:filter hover:brightness-[80%]",
    "low" =>
      "bg-white border border-brightGray-300 flex cursor-pointer h-6 items-center justify-center rounded w-6 before:content-[''] before:block before:w-4 before:h-1 before:bg-brightGray-300 peer-checked:bg-brightGreen-300 peer-checked:border-brightGreen-300 peer-checked:before:bg-white hover:filter hover:brightness-[80%]"
  }

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign_display_user(params)
    |> assign_skill_panel(params["skill_panel_id"])
    |> assign(:select_label, "now")
    |> assign(:select_label_compared_user, nil)
    |> assign(:compared_user, nil)
    |> assign(:page_title, "スキルパネル")
    |> assign(:selected_unit, nil)
    |> assign(:gem_labels, [])
    |> assign(:gem_values, nil)
    |> push_event("scroll_to_unit", %{})
    |> assign(:skill_share_open, false)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, url, %{assigns: %{skill_panel: %SkillPanel{}} = assigns} = socket) do
    socket
    |> assign_path(url)
    |> assign_skill_classes()
    |> assign_skill_share_data()
    |> assign_skill_class_and_score(params["class"])
    |> create_skill_class_score_if_not_existing()
    |> assign_skill_score_dict()
    |> assign_skill_units()
    |> assign_row_dict()
    |> assign_counter()
    |> assign_gem_data()
    |> assign(:links, create_links(assigns))
    |> apply_action(socket.assigns.live_action, params)
    |> ShareHelper.assign_share_graph_url()
    |> assign(encode_share_ogp: Aes128.encrypt("#{socket.assigns.skill_panel.id}},ogp"))
    |> touch_user_skill_panel()
    |> then(&{:noreply, &1})
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

  defp assign_skill_units(socket) do
    skill_units =
      socket.assigns.skill_class
      |> Bright.Repo.preload(skill_units: [skill_categories: [:skills]])
      |> Map.get(:skill_units)

    assign(socket, :skill_units, skill_units)
  end

  defp assign_row_dict(socket) do
    # 指定行をハイライトすることなどのためのUI便宜上の準備
    dict =
      socket.assigns.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)
      |> Enum.with_index(1)
      |> Map.new(fn {skill, row} -> {skill.id, row} end)

    socket
    |> assign(:row_dict, dict)
    |> assign(:num_skills, Enum.count(dict))
  end

  defp update_by_score_change(socket, skill_score, score) do
    # 表示スコア更新
    # 永続化は全体一括のため、ここでは実施してない
    skill_score_dict =
      socket.assigns.skill_score_dict
      |> Map.put(skill_score.skill_id, %{skill_score | score: score, changed: true})

    socket
    |> assign(:skill_score_dict, skill_score_dict)
    |> assign_counter()
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

  defp assign_first_time(socket) do
    # スキルを初めて入力したときのメッセージ表示用のフラグ管理
    %{user: user, skill_class: skill_class, skill_score_dict: skill_score_dict} = socket.assigns
    skill_scores = Map.values(skill_score_dict)
    first_time_in_skill_panel = skill_class.class == 1 && Enum.all?(skill_scores, &(&1.id == nil))

    first_time_overall =
      first_time_in_skill_panel && !SkillScores.get_user_entered_skill_score_at_least_one?(user)

    socket
    |> assign(:first_time_in_overall, first_time_overall)
    |> assign(:first_time_in_skill_panel, first_time_in_skill_panel)
  end

  defp maybe_update_skill_card_component(skill_class_score) do
    prev_level = skill_class_score.level
    prev_percentage = skill_class_score.percentage

    skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
    new_level = skill_class_score.level
    new_percentage = skill_class_score.percentage

    if prev_level != new_level do
      send_update(SkillCardComponent, id: "skill_card", status: "level_changed")
    end

    if prev_level != new_level && prev_percentage < new_percentage do
      # レベルアップ時の表示モーダル
      # TODO: 現在はガワだけ実装のためコメントアウトしている。シェアするURLやOGPに対応したら有効化する
      send_update(GrowthShareModalComponent,
        id: "growth_share",
        open: true,
        user_id: skill_class_score.user_id,
        skill_class_id: skill_class_score.skill_class_id
      )
    end
  end

  # スキル初回入力（全体初）後に表示するメッセージのためのflashを設定
  defp put_flash_first_submit_in_overall(socket) do
    socket.assigns.first_time_in_overall
    |> if(do: put_flash(socket, :first_submit_in_overall, true), else: socket)
  end

  # スキル初回入力（本スキルパネル初）後に表示するメッセージのためのflashを設定
  defp put_flash_first_submit_in_skill_panel(socket) do
    socket.assigns.first_time_in_skill_panel
    |> if(do: put_flash(socket, :first_submit_in_skill_panel, true), else: socket)
  end

  defp push_scroll_to(socket) do
    %{focus_row: row} = socket.assigns
    # キーショートカットによる入力時スクロール
    push_event(socket, "scroll-to-parent", %{
      target: "skill-#{row}-form",
      parent_selector: ".category-top"
    })
  end

  defp score_mark_class, do: @score_mark_class

  defp get_level(counter, num_skills) do
    percentage = SkillScores.calc_high_skills_percentage(counter.high, num_skills)
    SkillScores.get_level(percentage)
  end

  defp minute_per_skill, do: @minute_per_skill

  defp create_links(assigns) do
    link = "#input-unit-"

    1..length(assigns.gem_labels)
    |> Enum.map(fn x -> link <> "#{x}" end)
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

  defp assign_skill_share_data(%{assigns: assigns} = socket) do
    skill_share_data =
      SkillScores.get_level_count_from_skill_panel_id(assigns.skill_panel.id)
      |> Map.merge(%{name: assigns.skill_panel.name})

    assign(socket, :skill_share_data, skill_share_data)
  end
end
