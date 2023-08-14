defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias Bright.Accounts

  import Phoenix.Component, only: [assign: 2, assign: 3]

  @counter %{
    low: 0,
    middle: 0,
    high: 0,
    exam_touch: 0,
    reference_read: 0,
    evidence_filled: 0
  }

  @queries ~w(class)

  def assign_path(socket, url) do
    %{path: path, query: query} = URI.parse(url)

    query =
      URI.decode_query(query || "")
      |> Map.take(@queries)

    socket
    |> assign(path: path)
    |> assign(query: query)
  end

  def assign_focus_user(socket, nil) do
    socket
    |> assign(focus_user: socket.assigns.current_user, me: true)
  end

  def assign_focus_user(socket, user_name) do
    user =
      Accounts.get_user_by_name(user_name)
      |> Bright.Repo.preload(:user_profile)

    # TODO: userを参照してよいかどうかアクセス制限が必要
    # （マイページと同様のはずなので共通処理を使う）
    # 現状は見つかったとしての実装

    socket
    |> assign(focus_user: user, me: false)
  end

  def assign_skill_panel(socket, nil) do
    focus_user = socket.assigns.focus_user

    skill_panel = SkillPanels.get_user_latest_skill_panel!(focus_user)

    socket
    |> assign(:skill_panel, skill_panel)
  end

  def assign_skill_panel(socket, skill_panel_id) do
    focus_user = socket.assigns.focus_user

    skill_panel =
      SkillPanels.get_user_skill_panel(focus_user, skill_panel_id) ||
        SkillPanels.get_user_latest_skill_panel!(focus_user)

    socket
    |> assign(:skill_panel, skill_panel)
  end

  def assign_skill_classes(socket) do
    focus_user = socket.assigns.focus_user

    skill_classes =
      Ecto.assoc(socket.assigns.skill_panel, :skill_classes)
      |> SkillPanels.list_skill_classes()
      |> Bright.Repo.preload(skill_class_scores: Ecto.assoc(focus_user, :skill_class_scores))

    socket
    |> assign(:skill_classes, skill_classes)
  end

  def assign_skill_class_and_score(socket, nil) do
    # 指定がない場合はもっとも最近編集されたクラスとする
    socket.assigns.skill_classes
    |> Enum.filter(&(&1.skill_class_scores != []))
    |> Enum.sort_by(
      fn skill_class ->
        skill_class.skill_class_scores
        |> List.first()
        |> Map.get(:updated_at)
      end,
      {:desc, NaiveDateTime}
    )
    |> List.first()
    |> case do
      nil -> 1
      skill_class_score -> skill_class_score.class
    end
    |> then(&assign_skill_class_and_score(socket, &1))
  end

  def assign_skill_class_and_score(socket, class) when is_bitstring(class) do
    assign_skill_class_and_score(socket, String.to_integer(class))
  end

  def assign_skill_class_and_score(socket, class) do
    skill_class = socket.assigns.skill_classes |> Enum.find(&(&1.class == class))
    # List.first(): preload時に絞り込んでいるためfirstで取得可能
    skill_class_score = skill_class.skill_class_scores |> List.first()

    socket
    |> assign(:skill_class, skill_class)
    |> assign(:skill_class_score, skill_class_score)
  end

  def create_skill_class_score_if_not_existing(
        %{
          assigns: %{
            me: true,
            skill_class_score: nil,
            skill_class: %{class: 1}
          }
        } = socket
      ) do
    # NOTE: skill_class_scoreが存在しないときの生成処理について
    # 管理側でスキルクラスを増やすなどの操作も想定し、
    # アクセスしたタイミングで生成するようにしています。
    user = socket.assigns.current_user
    skill_class = socket.assigns.skill_class

    {:ok, _} = SkillScores.create_skill_class_score(user, skill_class)

    skill_class_score =
      SkillScores.get_skill_class_score_by!(
        user_id: user.id,
        skill_class_id: skill_class.id
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

    skills =
      skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    socket
    |> assign(skill_units: skill_units)
    |> assign(skills: skills)
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
