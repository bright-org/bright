defmodule BrightWeb.SkillPanelLive.SkillPanelHelper do
  import Phoenix.Component, only: [assign: 2, assign: 3]

  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.SkillScores
  alias BrightWeb.DisplayUserHelper
  alias Bright.UserSkillPanels
  alias Bright.Teams
  alias Bright.Utils.GoogleCloud.Storage

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
    |> assign_is_star(display_user, skill_panel)
  end

  def assign_skill_panel(socket, %{skill_panel_id: nil} = skill_panel_params) do
    latest_panel = SkillPanels.get_user_latest_skill_panel(socket.assigns.display_user)

    skill_panel =
      skill_panel_params
      |> Map.put(:skill_panel_id, latest_panel.id)
      |> UserSkillPanels.find_or_create_skill_panel()

    raise_if_not_exists_skill_panel(skill_panel)

    assign(socket, :skill_panel, skill_panel)
    |> assign_is_star(socket.assigns.display_user, skill_panel)
  end

  def assign_skill_panel(socket, skill_panel_params) when is_map(skill_panel_params) do
    skill_panel =
      if socket.assigns.me do
        UserSkillPanels.find_or_create_skill_panel(skill_panel_params)
      else
        SkillPanels.get_user_skill_panel(
          socket.assigns.display_user,
          skill_panel_params.skill_panel_id
        )
      end

    raise_if_not_exists_skill_panel(skill_panel)

    assign(socket, :skill_panel, skill_panel)
    |> assign_is_star(socket.assigns.display_user, skill_panel)
  end

  def assign_skill_panel(socket, skill_panel_id) do
    skill_panel = SkillPanels.get_user_skill_panel(socket.assigns.display_user, skill_panel_id)

    raise_if_not_exists_skill_panel(skill_panel)

    assign(socket, :skill_panel, skill_panel)
    |> assign_is_star(socket.assigns.display_user, skill_panel)
  end

  def assign_is_star(socket, _display_user, nil), do: assign(socket, :is_star, false)

  def assign_is_star(socket, display_user, skill_panel) do
    is_star = Bright.UserSkillPanels.get_is_star!(display_user.id, skill_panel.id)
    assign(socket, :is_star, is_star)
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
    # NOTE: 現在はスキルパネル取得時に全クラスのスキルクラススコアを生成している。本処理は後方互換性のために残している。
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

    socket
    |> assign(skill_score_dict: get_skill_score_dict(skill_class_score))
  end

  def get_skill_score_dict(skill_class_score) do
    skills = SkillUnits.list_skills_on_skill_class(%{id: skill_class_score.skill_class_id})

    # skillからskill_scoreを引く辞書を生成
    # skillに対して未作成のときは、フォームの都合でStructで初期化
    skill_score_dict =
      SkillScores.list_user_skill_scores_from_skill_ids(
        Enum.map(skills, & &1.id),
        skill_class_score.user_id
      )
      |> Map.new(&{&1.skill_id, &1})

    Map.new(skills, fn skill ->
      skill_score =
        Map.get(skill_score_dict, skill.id)
        |> Kernel.||(%SkillScores.SkillScore{skill_id: skill.id, score: :low})
        |> Map.put(:changed, false)

      {skill.id, skill_score}
    end)
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
        # TODO: リファクタリング PathHelperを使えるか確認・対応
        {:ok, build_path(root, display_user_skill_panel, user, false, anonymous)}
    end
  end

  def comparable_user?(target_user, assigns) do
    %{
      current_user: current_user,
      compared_users: compared_users,
      display_user: display_user
    } = assigns

    !already_compared?(target_user, compared_users, display_user) &&
      viewable_user?(target_user, current_user)
  end

  defp already_compared?(target_user, compared_users, nil) do
    target_user.id in Enum.map(compared_users, & &1.id)
  end

  defp already_compared?(target_user, compared_users, display_user) do
    target_user.id == display_user.id ||
      target_user.id in Enum.map(compared_users, & &1.id)
  end

  defp viewable_user?(%{anonymous: true} = _target_user, _current_user) do
    # 匿名の場合は表示も匿名なのでチェック無しで表示可能
    true
  end

  defp viewable_user?(target_user, current_user) do
    # チームに所属している、
    # または支援関係にあるチームに所属している人のみ実名表示可能
    Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
      current_user.id,
      target_user.id
    )

    true
  rescue
    Bright.Exceptions.ForbiddenResourceError -> false
  end

  defp raise_invalid_skill_class do
    # 保有スキルパネルに存在しないクラスなどへのアクセスにあたる。404で返す。
    # 導線はなく、クエリストリングで指定される可能性がある。
    raise Ecto.NoResultsError, queryable: "Bright.SkillPanels.SkillClass"
  end

  defp raise_if_not_exists_skill_panel(nil) do
    # 指定のスキルパネルが存在しない場合は404で返す。
    # 導線はなく、URLで指定される可能性がある。
    raise Ecto.NoResultsError, queryable: "Bright.SkillPanels.SkillPanel"
  end

  defp raise_if_not_exists_skill_panel(_skill_panel), do: nil

  def assign_og_image_data(socket, value, key \\ :og_image_data) do
    [_, value] = String.split(value, ",")
    value = Base.decode64!(value)
    assign(socket, key, value)
  end

  def upload_ogp_data(assigns, data_key \\ :og_image_data) do
    base_name = get_bese_name(assigns, data_key)

    file_name = "#{base_name}.png"
    og_image_data = Map.get(assigns, data_key)
    local_file_name = "#{System.tmp_dir()}/#{file_name}"
    File.write(local_file_name, og_image_data)
    :ok = Storage.upload!(local_file_name, "ogp/" <> file_name)
    File.rm(local_file_name)
  end

  defp get_bese_name(assigns, :skill_shara_og_image_data), do: assigns.encode_share_ogp
  defp get_bese_name(assigns, :og_image_data), do: assigns.encode_share_graph_token
end
