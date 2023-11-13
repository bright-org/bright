defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  import Phoenix.Component, only: [assign: 2, assign: 3]

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias BrightWeb.DisplayUserHelper
  alias Bright.UserSkillPanels

  @counter %{
    low: 0,
    middle: 0,
    high: 0,
    exam_touch: 0,
    reference_read: 0,
    evidence_filled: 0
  }

  # queries: patch遷移時に保持するパラメータ
  # NOTE:
  #   初期状態を指定するteamなどのパラメータは含めないこと。
  #   含めるとその状態で初期化される。
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

  def assign_skill_panel(socket, nil) do
    display_user = socket.assigns.display_user
    skill_panel = SkillPanels.get_user_latest_skill_panel(display_user)
    assign(socket, :skill_panel, skill_panel)
  end

  def assign_skill_panel(socket, skill_panel_id) do
    raise_if_not_ulid(skill_panel_id)

    skill_panel = SkillPanels.get_user_skill_panel(socket.assigns.display_user, skill_panel_id)

    raise_if_not_exists_skill_panel(skill_panel)

    assign(socket, :skill_panel, skill_panel)
  end

  def assign_skill_classes(socket) do
    display_user = socket.assigns.display_user

    skill_classes =
      socket.assigns.skill_panel
      |> Bright.Repo.preload(
        skill_classes: [skill_class_scores: Ecto.assoc(display_user, :skill_class_scores)]
      )
      |> Map.get(:skill_classes)

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

  def assign_skill_class_and_score(socket, class) when class in ~w(1 2 3) do
    assign_skill_class_and_score(socket, String.to_integer(class))
  end

  def assign_skill_class_and_score(socket, class) when class in [1, 2, 3] do
    skill_class = socket.assigns.skill_classes |> Enum.find(&(&1.class == class))

    if skill_class do
      # List.first(): preload時に絞り込んでいるためfirstで取得可能
      skill_class_score = skill_class.skill_class_scores |> List.first()

      socket
      |> assign(:skill_class, skill_class)
      |> assign(:skill_class_score, skill_class_score)
    else
      raise_invalid_skill_class()
    end
  end

  def assign_skill_class_and_score(_socket, _class) do
    raise_invalid_skill_class()
  end

  def create_skill_class_score_if_not_existing(
        %{assigns: %{me: true, skill_class_score: nil}} = socket
      ) do
    # 始めてスキルクラスにアクセスした際にスキルクラススコアを生成
    user = socket.assigns.current_user
    skill_class = socket.assigns.skill_class

    {:ok, _} = SkillScores.create_skill_class_score(skill_class, user.id)

    skill_class_score =
      SkillScores.get_skill_class_score_by!(
        user_id: user.id,
        skill_class_id: skill_class.id
      )

    socket
    |> assign(skill_class_score: skill_class_score)
  end

  def create_skill_class_score_if_not_existing(socket), do: socket

  def assign_skill_score_dict(%{assigns: %{skill_class_score: nil}}) do
    # 保有スキルパネルの開放していないクラスへのアクセスにあたるので404で返す。
    # 導線はなく、クエリストリングで指定される可能性がある。
    raise Ecto.NoResultsError, queryable: "Bright.SkillScores.SkillClassScore"
  end

  def assign_skill_score_dict(socket) do
    %{skill_class_score: skill_class_score} = socket.assigns
    skills = SkillUnits.list_skills_on_skill_class(%{id: skill_class_score.skill_class_id})

    # skillからskill_scoreを引く辞書を生成
    # skillに対して未作成のときは、フォームの都合でStructで初期化
    skill_score_dict =
      SkillScores.list_user_skill_scores_from_skill_ids(
        Enum.map(skills, & &1.id),
        skill_class_score.user_id
      )
      |> Map.new(&{&1.skill_id, &1})

    skill_score_dict =
      Map.new(skills, fn skill ->
        skill_score =
          Map.get(skill_score_dict, skill.id)
          |> Kernel.||(%SkillScores.SkillScore{skill_id: skill.id, score: :low})
          |> Map.put(:changed, false)

        {skill.id, skill_score}
      end)

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

  def touch_user_skill_panel(%{assigns: %{me: true}} = socket) do
    UserSkillPanels.touch_user_skill_panel_updated(
      socket.assigns.current_user,
      socket.assigns.skill_panel
    )

    socket
  end

  def touch_user_skill_panel(socket), do: socket

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

  def get_path_to_switch_me(root, user, skill_panel) do
    SkillPanels.get_user_skill_panel(user, skill_panel.id)
    |> case do
      nil -> "/#{root}"
      _ -> "/#{root}/#{skill_panel.id}"
    end
  end

  def get_path_to_switch_display_user(root, user, skill_panel, anonymous) do
    display_user_skill_panel =
      SkillPanels.get_user_skill_panel(user, skill_panel.id) ||
        SkillPanels.get_user_latest_skill_panel(user)

    display_user_skill_panel
    |> case do
      nil ->
        # 保有スキルパネルが1つもない場合は表示不可のためpathを返さない
        :error

      _ ->
        {:ok, build_path(root, display_user_skill_panel, user, false, anonymous)}
    end
  end

  defp raise_invalid_skill_class do
    # 保有スキルパネルに存在しないクラスなどへのアクセスにあたる。404で返す。
    # 導線はなく、クエリストリングで指定される可能性がある。
    raise Ecto.NoResultsError, queryable: "Bright.SkillPanels.SkillClass"
  end

  def raise_if_not_ulid(ulid) do
    # スキルパネルの指定が不正だった場合は404で返す。
    # 導線はなく、URLで指定される可能性がある。
    Ecto.ULID.cast(ulid)
    |> case do
      {:ok, _} -> nil
      _ -> raise Ecto.NoResultsError, queryable: "Bright.SkillPanels.SkillPanel"
    end
  end

  defp raise_if_not_exists_skill_panel(nil) do
    # 指定のスキルパネルが存在しない場合は404で返す。
    # 導線はなく、URLで指定される可能性がある。
    raise Ecto.NoResultsError, queryable: "Bright.SkillPanels.SkillPanel"
  end

  defp raise_if_not_exists_skill_panel(_skill_panel), do: nil
end
