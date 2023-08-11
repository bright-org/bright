defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores

  import Phoenix.Component, only: [assign: 2, assign: 3]

  @counter %{
    low: 0,
    middle: 0,
    high: 0,
    exam_touch: 0,
    reference_read: 0,
    evidence_filled: 0
  }

  def assign_skill_panel(socket, "dummy_id") do
    # TODO dummy_idはダミー用で実装完了後に消すこと
    skill_panel =
      SkillPanels.list_skill_panels()
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})
      |> List.first()

    assign_skill_panel(socket, skill_panel.id)
  end

  def assign_skill_panel(socket, skill_panel_id) do
    current_user = socket.assigns.current_user

    skill_panel =
      SkillPanels.get_skill_panel!(skill_panel_id)
      |> Bright.Repo.preload(
        skill_classes: [skill_class_scores: Ecto.assoc(current_user, :skill_class_scores)]
      )

    socket
    |> assign(:skill_panel, skill_panel)
  end

  def assign_skill_class_and_score(socket, nil), do: assign_skill_class_and_score(socket, "1")

  def assign_skill_class_and_score(socket, class) do
    class = String.to_integer(class)
    skill_class = socket.assigns.skill_panel.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  def create_skill_class_score_if_not_existing(%{assigns: %{skill_class_score: nil}} = socket) do
    # NOTE: skill_class_scoreが存在しないときの生成処理について
    # 管理側でスキルクラスを増やすなどの操作も想定し、
    # アクセスしたタイミングで生成するようにしています。

    # TODO: クラス開放処理実装時に対応
    # - クラス開放が必要のないclass=1のみを対象とする
    # - クラス開放が必要なものはここではなく解放時に作成する
    {:ok, %{skill_class_score: skill_class_score}} =
      SkillScores.create_skill_class_score(
        socket.assigns.current_user,
        socket.assigns.skill_class
      )

    socket
    |> assign(skill_class_score: skill_class_score)
  end

  def create_skill_class_score_if_not_existing(socket), do: socket

  def assign_skill_units(socket) do
    skill_units =
      Ecto.assoc(socket.assigns.skill_class, :skill_units)
      |> SkillUnits.list_skill_units()
      |> Bright.Repo.preload(skill_categories: [skills: [:skill_reference, :skill_exam]])

    socket
    |> assign(skill_units: skill_units)
  end

  def assign_skill_score_dict(socket) do
    skill_score_dict =
      socket.assigns.skill_class_score
      |> SkillScores.list_skill_scores_from_skill_class_score()
      |> Map.new(&{&1.skill_id, Map.put(&1, :changed, false)})

    socket
    |> assign(skill_score_dict: skill_score_dict)
  end

  def assign_counter(socket) do
    counter =
      socket.assigns.skill_score_dict
      |> Map.values()
      |> Enum.reduce(@counter, fn skill_score, acc ->
        acc
        |> Map.update!(skill_score.score, &(&1 + 1))
        |> Map.update!(:exam_touch, &if(skill_score.exam_progress, do: &1 + 1, else: &1))
        |> Map.update!(:reference_read, &if(skill_score.reference_read, do: &1 + 1, else: &1))
        |> Map.update!(:evidence_filled, &if(skill_score.evidence_filled, do: &1 + 1, else: &1))
      end)

    num_skills = Enum.count(socket.assigns.skill_score_dict)

    socket
    |> assign(counter: counter, num_skills: num_skills)
  end

  def assign_page_sub_title(socket) do
    socket
    |> assign(:page_sub_title, socket.assigns.skill_panel.name)
  end

  def calc_percentage(_count, 0), do: 0

  def calc_percentage(count, num_skills) do
    (count / num_skills)
    |> Kernel.*(100)
    |> floor()
  end
end
