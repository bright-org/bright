defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  alias Bright.SkillPanels
  alias Bright.SkillScores

  import Phoenix.Component, only: [assign: 2, assign: 3]
  import Phoenix.LiveView, only: [push_redirect: 2]

  alias BrightWeb.DisplayUserHelper

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

  def assign_skill_panel(socket, nil, _root) do
    display_user = socket.assigns.display_user

    skill_panel = SkillPanels.get_user_latest_skill_panel!(display_user)

    socket
    |> assign(:skill_panel, skill_panel)
  end

  def assign_skill_panel(socket, skill_panel_id, root) do
    display_user = socket.assigns.display_user

    skill_panel = SkillPanels.get_user_skill_panel(display_user, skill_panel_id)

    if skill_panel do
      socket
      |> assign(:skill_panel, skill_panel)
    else
      # 指定されているスキルパネルがない場合は、
      # 直近のスキルパネルを取得して、
      # URLと矛盾した表示にならないようにリダイレクト
      skill_panel = SkillPanels.get_user_latest_skill_panel!(display_user)

      path =
        build_path(root, skill_panel, display_user, socket.assigns.me, socket.assigns.anonymous)

      socket
      |> assign(:skill_panel, nil)
      |> push_redirect(to: path)
    end
  end

  def assign_skill_classes(socket) do
    display_user = socket.assigns.display_user

    skill_classes =
      Ecto.assoc(socket.assigns.skill_panel, :skill_classes)
      |> SkillPanels.list_skill_classes()
      |> Bright.Repo.preload(skill_class_scores: Ecto.assoc(display_user, :skill_class_scores))

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

  def assign_skill_score_dict(socket) do
    skill_score_dict =
      socket.assigns.skill_class_score
      |> SkillScores.list_skill_scores_from_skill_class_score()
      |> Map.new(&{&1.skill_id, Map.put(&1, :changed, false)})

    socket
    |> assign(skill_score_dict: skill_score_dict)
  end

  def assign_counter(socket) do
    counter = count_skill_scores(socket.assigns.skill_score_dict)
    num_skills = Enum.count(socket.assigns.skill_score_dict)

    socket
    |> assign(counter: counter, num_skills: num_skills)
  end

  def count_skill_scores(skill_score_dict) do
    skill_score_dict
    |> Map.values()
    |> Enum.reduce(@counter, fn skill_score, acc ->
      acc
      |> Map.update!(skill_score.score, &(&1 + 1))
      |> Map.update!(:exam_touch, &if(skill_score.exam_progress, do: &1 + 1, else: &1))
      |> Map.update!(:reference_read, &if(skill_score.reference_read, do: &1 + 1, else: &1))
      |> Map.update!(:evidence_filled, &if(skill_score.evidence_filled, do: &1 + 1, else: &1))
    end)
  end

  def assign_page_sub_title(%{assigns: %{skill_panel: nil}} = socket) do
    socket
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

  def build_path(root, skill_panel, display_user, me, anonymous)

  def build_path(root, skill_panel, _display_user, true, _anonymous) do
    # 自ユーザー
    "/#{root}/#{skill_panel.id}"
  end

  def build_path(root, skill_panel, display_user, _me, true) do
    # 対象ユーザーかつ匿名
    encrypted = DisplayUserHelper.encrypt_user_name(display_user)
    "/#{root}/#{skill_panel.id}/anon/#{encrypted}"
  end

  def build_path(root, skill_panel, display_user, _me, false) do
    # 対象ユーザーかつ匿名ではない
    "/#{root}/#{skill_panel.id}/#{display_user.name}"
  end
end
