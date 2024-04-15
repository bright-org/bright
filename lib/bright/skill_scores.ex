defmodule Bright.SkillScores do
  @moduledoc """
  The SkillScores context.
  """

  import Ecto.Query, warn: false

  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.SkillPanels
  alias Bright.SkillUnits
  alias Bright.CareerFields
  alias Bright.HistoricalSkillScores

  alias Bright.SkillScores.{
    SkillClassScore,
    SkillUnitScore,
    SkillScore,
    CareerFieldScore,
    SkillClassScoreLog
  }

  alias Bright.Notifications
  alias Bright.Utils.Percentage

  # レベルの判定値
  @normal_level 40
  @skilled_level 60
  @master_level 100

  @doc """
  Return level judgment value.
  ## Examples
      iex> get_level_judgment_value((:normal))
      40
  """

  def get_level_judgment_value(:normal), do: @normal_level
  def get_level_judgment_value(:skilled), do: @skilled_level
  def get_level_judgment_value(:master), do: @master_level

  @doc """
  Returns the list of skill_class_scores.

  ## Examples

      iex> list_skill_class_scores()
      [%SkillClassScore{}, ...]

  """
  def list_skill_class_scores do
    Repo.all(SkillClassScore)
  end

  def list_users_skill_class_scores_by_skill_panel_id(
        user_ids,
        skill_panel_id,
        page_param \\ %{page: 1, page_size: 1}
      ) do
    from(
      scs in SkillClassScore,
      join: sc in assoc(scs, :skill_class),
      on: scs.skill_class_id == sc.id,
      where: sc.skill_panel_id == ^skill_panel_id and scs.user_id in ^user_ids
    )
    |> preload(:skill_class)
    |> Repo.paginate(page_param)
  end

  @doc """
  Gets a single skill_class_score.

  Raises `Ecto.NoResultsError` if the Skill score does not exist.

  ## Examples

      iex> get_skill_class_score!(123)
      %SkillClassScore{}

      iex> get_skill_class_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_class_score!(id), do: Repo.get!(SkillClassScore, id)

  def get_skill_class_score_by(condition), do: Repo.get_by(SkillClassScore, condition)

  def get_skill_class_score_by!(condition), do: Repo.get_by!(SkillClassScore, condition)

  @doc """
  Creates a skill_class_score with skill_scores
  """
  def create_skill_class_score(skill_class, user_id) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:skill_class_score_init, %SkillClassScore{
      user_id: user_id,
      skill_class_id: skill_class.id
    })
    # 初期更新
    # 共有スキルユニットが含まれるケースでは作成時にスコアが存在する
    |> Ecto.Multi.run(:skill_class_score, fn _repo, data ->
      skill_class_score = Map.get(data, :skill_class_score_init)
      update_skill_class_score_stats(skill_class_score, skill_class)
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a skill_class_score aggregation columns.
  """
  def update_skill_class_score_stats(skill_class_score, skill_class) do
    skills = SkillUnits.list_skills_on_skill_class(skill_class)

    skill_scores =
      list_user_skill_scores_from_skill_ids(
        Enum.map(skills, & &1.id),
        skill_class_score.user_id
      )

    size = Enum.count(skills)
    high_scores_count = Enum.count(skill_scores, &(&1.score == :high))
    percentage = Percentage.calc_percentage(high_scores_count, size)
    level = get_level(percentage)

    changeset =
      change_skill_class_score(skill_class_score, %{percentage: percentage, level: level})

    notification_attrs_list = build_notifications_by_skill_class_score_change(changeset)
    log_attrs = build_log_by_skill_class_score_change(changeset)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:update_skill_class_score, changeset)
    |> then_if_existing(notification_attrs_list, fn multi, values ->
      Ecto.Multi.insert_all(
        multi,
        :insert_all_notifications,
        Notifications.NotificationSkillUpdate,
        values
      )
    end)
    |> then_if_existing(log_attrs, fn multi, value ->
      Ecto.Multi.insert(multi, :skill_class_score_log, value)
    end)
    |> Repo.transaction()
  end

  @doc """
  Updates a skill_class_scores aggregation columns.
  """
  def update_skill_class_scores_stats(skill_classes, user) do
    skill_classes
    |> Repo.preload(skill_class_scores: SkillClassScore.user_query(user))
    |> Enum.filter(&(&1.skill_class_scores != []))
    |> Enum.reduce(Ecto.Multi.new(), fn skill_class, multi ->
      skill_class_score = List.first(skill_class.skill_class_scores)

      multi
      |> Ecto.Multi.run(:"skill_class_score_#{skill_class_score.id}", fn _repo, _ ->
        update_skill_class_score_stats(skill_class_score, skill_class)
      end)
    end)
    |> Repo.transaction()
  end

  @doc """
  Returns the level determined by percentage.
  """
  def get_level(percentage) do
    percentage
    |> case do
      v when v >= @skilled_level -> :skilled
      v when v >= @normal_level -> :normal
      _ -> :beginner
    end
  end

  defp change_skill_class_score(skill_class_score, attrs) do
    # Returns skill_class_score changeset.
    base_changeset = SkillClassScore.changeset(skill_class_score, attrs)
    time_now = NaiveDateTime.utc_now()

    additional_attrs =
      {base_changeset.changes, skill_class_score}
      |> case do
        {%{level: :normal}, %{became_normal_at: nil}} ->
          %{became_normal_at: time_now}

        {%{level: :skilled}, %{became_normal_at: nil, became_skilled_at: nil}} ->
          %{became_normal_at: time_now, became_skilled_at: time_now}

        {%{level: :skilled}, %{became_skilled_at: nil}} ->
          %{became_skilled_at: time_now}

        _ ->
          %{}
      end

    # 追加属性込みのchangesetを再作成して返す
    SkillClassScore.changeset(skill_class_score, Map.merge(attrs, additional_attrs))
  end

  defp build_notifications_by_skill_class_score_change(changeset) do
    # スキルクラススコアの変更内容に伴う通知の作成分を返す
    changeset.changes
    |> case do
      %{became_normal_at: _, became_skilled_at: _} ->
        # 同時に達成している場合はskilled(上位)通知のみ生成
        build_notification_attrs(changeset.data, :skilled)

      %{became_normal_at: _} ->
        build_notification_attrs(changeset.data, :normal)

      %{became_skilled_at: _} ->
        build_notification_attrs(changeset.data, :skilled)

      _ ->
        # changeされていないときは通知生成しないため返さない
        []
    end
  end

  defp build_notification_attrs(skill_class_score, level) do
    user = Accounts.get_user!(skill_class_score.user_id)
    skill_class = SkillPanels.get_skill_class!(skill_class_score.skill_class_id)
    skill_panel = SkillPanels.get_skill_panel!(skill_class.skill_panel_id)

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    base_attrs = %{
      from_user_id: user.id,
      message:
        "#{user.name}さんが#{skill_panel.name}【#{skill_class.name}】で「#{Gettext.gettext(BrightWeb.Gettext, "level_#{level}")}」レベルになりました",
      url: "/panels/#{skill_panel.id}/#{user.name}?class=#{skill_class.class}",
      inserted_at: timestamp,
      updated_at: timestamp
    }

    Notifications.list_related_user_ids(user)
    |> Enum.map(fn user_id ->
      Map.merge(base_attrs, %{
        id: Ecto.ULID.generate(),
        to_user_id: user_id
      })
    end)
  end

  defp build_log_by_skill_class_score_change(changeset) do
    # スキルクラススコアの変更内容に伴うスキルクラススコアログの作成分を返す
    Map.has_key?(changeset.changes, :percentage)
    |> if do
      %SkillClassScoreLog{
        user_id: changeset.data.user_id,
        skill_class_id: changeset.data.skill_class_id,
        date: Date.utc_today(),
        percentage: changeset.changes.percentage
      }
    end
  end

  defp then_if_existing(acc, [], _func), do: acc

  defp then_if_existing(acc, nil, _func), do: acc

  defp then_if_existing(acc, args, func), do: func.(acc, args)

  @doc """
  Returns the list of skill_scores.

  ## Examples

      iex> list_skill_scores()
      [%SkillScore{}, ...]

  """
  def list_skill_scores(query \\ SkillScore) do
    query
    |> Repo.all()
  end

  @doc """
  Returns the list of skill_scores from skill_class_score
  """
  def list_skill_scores_from_skill_class_score(%{skill_class_id: skill_class_id, user_id: user_id}) do
    SkillUnits.list_skills_on_skill_class(%{id: skill_class_id})
    |> Repo.preload(skill_scores: SkillScore.user_id_query(user_id))
    |> Enum.flat_map(& &1.skill_scores)
  end

  @doc """
  Returns the list of skill_scores from user and skill_ids
  """
  def list_user_skill_scores_from_skill_ids(skill_ids, user_id) do
    SkillScore.user_id_query(user_id)
    |> SkillScore.skill_ids_query(skill_ids)
    |> list_skill_scores()
  end

  @doc """
  Gets a single skill_score.

  Raises `Ecto.NoResultsError` if the Skill score item does not exist.

  ## Examples

      iex> get_skill_score!(123)
      %SkillScore{}

      iex> get_skill_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_score!(id), do: Repo.get!(SkillScore, id)

  @doc """
  Gets a single last updated skill_score
  """
  def get_latest_skill_score(user_id) do
    from(
      ss in SkillScore,
      where: ss.user_id == ^user_id,
      order_by: [desc: :updated_at],
      limit: 1
    )
    |> Repo.one()
  end

  @doc """
  Creates a skill_score.

  ## Examples

      iex> create_skill_score(%{field: value})
      {:ok, %SkillScore{}}

      iex> create_skill_score(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_score!(attrs \\ %{}) do
    %SkillScore{}
    |> SkillScore.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a skill_score.

  ## Examples

      iex> update_skill_score(skill_score, %{field: new_value})
      {:ok, %SkillScore{}}

      iex> update_skill_score(skill_score, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_score(%SkillScore{} = skill_score, attrs) do
    skill_score
    |> SkillScore.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns whether the given user has entered at least one skill score.
  """
  def get_user_entered_skill_score_at_least_one?(user) do
    Ecto.assoc(user, :skill_scores)
    |> Repo.exists?()
  end

  @doc """
  Makes a skill_score's evidence_filled
  """
  def make_skill_score_evidence_filled(user, skill) do
    get_or_insert_skill_score!(user, skill)
    |> update_skill_score(%{evidence_filled: true})
  end

  @doc """
  Makes a skill_score's reference_read
  """
  def make_skill_score_reference_read(user, skill) do
    get_or_insert_skill_score!(user, skill)
    |> update_skill_score(%{reference_read: true})
  end

  @doc """
  Makes a skill_score's exam_progress value
  """
  def make_skill_score_exam_progress(user, skill, progress) do
    get_or_insert_skill_score!(user, skill)
    |> update_skill_score(%{exam_progress: progress})
  end

  defp get_or_insert_skill_score!(user, skill) do
    Repo.get_by(SkillScore, user_id: user.id, skill_id: skill.id) ||
      Repo.insert!(%SkillScore{user_id: user.id, skill_id: skill.id})
  end

  @doc """
  Inserts or updates skill_scores.
  """
  def insert_or_update_skill_scores(skill_scores, user) do
    # 更新対象のスキルが属するスキルユニット/スキルクラスは集計更新対象
    skill_units =
      skill_scores
      |> Repo.preload(skill: [skill_category: [:skill_unit]])
      |> Enum.map(& &1.skill.skill_category.skill_unit)
      |> Enum.uniq()

    skill_classes =
      skill_units
      |> Repo.preload(:skill_classes)
      |> Enum.flat_map(& &1.skill_classes)
      |> Enum.uniq()

    skill_scores
    |> Enum.reduce(Ecto.Multi.new(), fn skill_score, multi ->
      skill_score.id
      |> if do
        # 更新：値はすでに保存済みなのでforce_changeでchangesetを構成
        changeset =
          skill_score
          |> Ecto.Changeset.change()
          |> Ecto.Changeset.force_change(:score, skill_score.score)

        Ecto.Multi.update(multi, :"skill_score_#{skill_score.id}", changeset)
      else
        # 新規
        skill_score = %{skill_score | user_id: user.id}
        Ecto.Multi.insert(multi, :"skill_score_new_#{skill_score.skill_id}", skill_score)
      end
    end)
    |> Ecto.Multi.run(:skill_unit_scores, fn _repo, _ ->
      insert_or_update_skill_unit_scores_stats(skill_units, user)
    end)
    |> Ecto.Multi.run(:skill_class_scores, fn _repo, _ ->
      update_skill_class_scores_stats(skill_classes, user)
    end)
    |> Repo.transaction()
  end

  @doc """
  Gets a single skill_unit_score.

  Raises `Ecto.NoResultsError` if the Skill score does not exist.

  ## Examples

      iex> get_skill_unit_score!(123)
      %SkillClassScore{}

      iex> get_skill_unit_score!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_unit_score!(id), do: Repo.get!(SkillUnitScore, id)

  @doc """
  Inserts or updates a skill_unit_score aggregation columns.
  """
  def insert_or_update_skill_unit_scores_stats(skill_units, user) do
    skill_units
    |> Repo.preload(
      skill_unit_scores: SkillUnitScore.user_query(user),
      skill_categories: [skills: [skill_scores: SkillScore.user_query(user)]]
    )
    |> Enum.reduce(Ecto.Multi.new(), fn skill_unit, multi ->
      skill_unit_score = List.first(skill_unit.skill_unit_scores)
      skills = skill_unit.skill_categories |> Enum.flat_map(& &1.skills)
      skill_scores = skills |> Enum.map(&List.first(&1.skill_scores)) |> Enum.filter(& &1)
      size = Enum.count(skills)
      high_scores_count = Enum.count(skill_scores, &(&1.score == :high))
      percentage = Percentage.calc_percentage(high_scores_count, size)

      skill_unit_score
      |> if do
        # 更新
        changeset = SkillUnitScore.changeset(skill_unit_score, %{percentage: percentage})
        Ecto.Multi.update(multi, :"skill_unit_score_#{skill_unit_score.id}", changeset)
      else
        # 新規
        changeset =
          %SkillUnitScore{skill_unit_id: skill_unit.id, user_id: user.id}
          |> SkillUnitScore.changeset(%{percentage: percentage})

        Ecto.Multi.insert(multi, :"skill_unit_score_new_#{skill_unit.id}", changeset)
      end
    end)
    |> Repo.transaction()
  end

  @doc """
  スキルのskill_scores.score: highの習得率(%)を返す。

  highの計算では切り捨てた数値を返す。
  highは完全習得時に100%と表示し99.5%などでは99%と表示する。
  """
  def calc_high_skills_percentage(value, size) do
    Percentage.calc_floor_percentage(value, size)
  end

  @doc """
  スキルのskill_scores.score: middleの習得率(%)を返す。

  middleの計算では切り上げた数値を返す。
  そうすることで半端な習得状況(33.3:66.6など)で、highの習得率(切り捨て)との合計を100にしている。
  """
  def calc_middle_skills_percentage(value, size) do
    Percentage.calc_ceil_percentage(value, size)
  end

  @doc """
  Get Skill Gem

  ## Examples

      iex> get_skill_gem(user_id, skill_panel_id, class)
      [
        %{
          name: "name",
          percentage: 50,
          position: 1
        }
     ]
  """
  def get_skill_gem(user_id, skill_panel_id, class) do
    from(skill_unit in SkillUnits.SkillUnit,
      join: skill_classes in assoc(skill_unit, :skill_classes),
      join: skill_class_units in assoc(skill_classes, :skill_class_units),
      on: skill_classes.class == ^class,
      on: skill_classes.skill_panel_id == ^skill_panel_id,
      on: skill_class_units.skill_unit_id == skill_unit.id,
      order_by: skill_class_units.position,
      preload: [
        skill_class_units: skill_class_units,
        skill_unit_scores: ^SkillUnitScore.user_id_query(user_id)
      ]
    )
    |> Repo.all()
    |> Enum.map(fn skill_unit ->
      skill_unit_score = List.first(skill_unit.skill_unit_scores)
      skill_class_unit = List.first(skill_unit.skill_class_units)

      %{
        name: skill_unit.name,
        percentage: Map.get(skill_unit_score || %{}, :percentage, 0.0),
        position: Map.get(skill_class_unit, :position),
        trace_id: skill_unit.trace_id
      }
    end)
  end

  @doc """
  Get Gem data for SkillSet
  """
  def get_skillset_gem(user_id) do
    career_fields = CareerFields.list_career_fields()

    career_field_ids_scores =
      from(q in CareerFieldScore, where: q.user_id == ^user_id)
      |> Repo.all()
      |> Map.new(&{&1.career_field_id, &1.percentage || 0.0})

    career_fields
    |> Enum.map(fn career_field ->
      %{
        position: career_field.position,
        name: career_field.name_ja,
        percentage: Map.get(career_field_ids_scores, career_field.id, 0.0)
      }
    end)
  end

  @doc """
  Get Skill Gem

  ## Examples

      iex> get_class_score(user_id, skill_panel_id, class)
      %SkillClassScore{}
  """
  def get_class_score(user_id, skill_panel_id, class) do
    from(skill_class_score in SkillClassScore,
      join: skill_class in assoc(skill_class_score, :skill_class),
      on: skill_class.class == ^class and skill_class.skill_panel_id == ^skill_panel_id,
      where: skill_class_score.user_id == ^user_id
    )
    |> Repo.one()
  end

  @doc """
  指定のスキルクラスに関わるスコア集計をまとめて再計算する
  NOTE: スキルパネル更新処理といった構造変更があったときを想定した重い処理
  """
  def re_aggregate_scores(skill_classes) do
    skill_classes = Repo.preload(skill_classes, [:skill_units])
    skill_units = skill_classes |> Enum.flat_map(& &1.skill_units) |> Enum.uniq()

    Ecto.Multi.new()
    |> Ecto.Multi.run(:all_skill_unit_scores, fn _repo, _data ->
      results = Enum.map(skill_units, &update_skill_unit_scores_associated_by/1)
      {:ok, results}
    end)
    |> Ecto.Multi.run(:all_skill_class_scores, fn _repo, _data ->
      results = Enum.map(skill_classes, &update_skill_class_scores_associated_by/1)
      {:ok, results}
    end)
    |> Repo.transaction()
  end

  defp update_skill_unit_scores_associated_by(skill_unit) do
    skill_unit =
      Repo.preload(skill_unit, [:skill_unit_scores, skill_categories: [skills: [:skill_scores]]])

    skills = skill_unit.skill_categories |> Enum.flat_map(& &1.skills)
    {skills_count, score_count_user_dict} = count_skill_scores_each_user(skills)

    # スキルユニットスコアの下記ケースを対応している。
    # - 作成済み => 更新
    # - 未作成 => 作成。未入力のスキルユニットに、他所の入力済みスキルが移動した場合に生じる
    skill_unit_scores = skill_unit.skill_unit_scores
    user_ids_already_created = Enum.map(skill_unit_scores, & &1.user_id)
    user_ids_to_create = Map.keys(score_count_user_dict) -- user_ids_already_created

    skill_unit_scores_new =
      Enum.map(user_ids_to_create, &%SkillUnitScore{user_id: &1, skill_unit_id: skill_unit.id})

    (skill_unit_scores ++ skill_unit_scores_new)
    |> Enum.reduce(Ecto.Multi.new(), fn skill_unit_score, multi ->
      user_id = skill_unit_score.user_id
      high_scores_count = get_in(score_count_user_dict, [user_id, :high]) || 0
      percentage = Percentage.calc_percentage(high_scores_count, skills_count)
      changeset = SkillUnitScore.changeset(skill_unit_score, %{percentage: percentage})

      skill_unit_score.id
      |> if do
        Ecto.Multi.update(multi, :"update_skill_unit_score_#{user_id}", changeset)
      else
        Ecto.Multi.insert(multi, :"create_skill_unit_score_#{user_id}", changeset)
      end
    end)
    |> Repo.transaction()
  end

  defp update_skill_class_scores_associated_by(skill_class) do
    skill_class =
      Repo.preload(skill_class, [
        :skill_class_scores,
        skill_units: [skill_categories: [skills: [:skill_scores]]]
      ])

    skills =
      skill_class.skill_units
      |> Enum.flat_map(& &1.skill_categories)
      |> Enum.flat_map(& &1.skills)

    {skills_count, score_count_user_dict} = count_skill_scores_each_user(skills)

    skill_class.skill_class_scores
    |> Enum.reduce(Ecto.Multi.new(), fn skill_class_score, multi ->
      user_id = skill_class_score.user_id
      high_scores_count = get_in(score_count_user_dict, [user_id, :high]) || 0
      percentage = Percentage.calc_percentage(high_scores_count, skills_count)
      level = get_level(percentage)

      changeset =
        change_skill_class_score(skill_class_score, %{percentage: percentage, level: level})

      notification_attrs_list = build_notifications_by_skill_class_score_change(changeset)
      log_attrs = build_log_by_skill_class_score_change(changeset)

      multi
      |> Ecto.Multi.update(:"update_skill_class_score_#{user_id}", changeset)
      |> then_if_existing(notification_attrs_list, fn multi, values ->
        Ecto.Multi.insert_all(
          multi,
          :"insert_all_notifications_#{user_id}",
          Notifications.NotificationSkillUpdate,
          values
        )
      end)
      |> then_if_existing(log_attrs, fn multi, value ->
        Ecto.Multi.insert(multi, :"skill_class_score_log_#{user_id}", value)
      end)
    end)
    |> Repo.transaction()
  end

  defp count_skill_scores_each_user(skills) do
    skills_count = Enum.count(skills)
    init_count = %{high: 0, middle: 0, low: 0}

    score_count_user_dict =
      Enum.reduce(skills, %{}, fn skill, acc ->
        Enum.reduce(skill.skill_scores, acc, fn skill_score, dict ->
          skill_dict =
            dict
            |> Map.get(skill_score.user_id, init_count)
            |> Map.update(skill_score.score, 1, &(&1 + 1))

          Map.put(dict, skill_score.user_id, skill_dict)
        end)
      end)

    {skills_count, score_count_user_dict}
  end

  @doc """
  スキルクラススコア変遷の取得
  """
  def get_skill_class_score_log_by(condition) do
    Repo.get_by(SkillClassScoreLog, condition)
  end

  @doc """
  スキルクラススコア変遷データの日付から日付までの取得
  """
  def list_skill_class_score_logs(user, skill_class, date_from, date_end) do
    from(scsl in SkillClassScoreLog,
      where: scsl.user_id == ^user.id,
      where: scsl.skill_class_id == ^skill_class.id,
      where: scsl.date >= ^date_from and scsl.date <= ^date_end,
      order_by: [{:asc, scsl.date}, {:asc, scsl.id}]
    )
    |> Repo.all()
  end

  @doc """
  スキルクラススコア変遷データを指定の過去日付から取得して返す

  最新のログは「現在」扱いに当たるため返さない
  直近(1つ前)のログの値は日付に関わらず最後にセットして返される
  それ以前の日付のログは日付単位で並べて値がセットして返される
  データがない日はnilが入っている
  """
  def list_user_skill_class_score_progress(user, skill_class, date_from, date_end) do
    # スキルクラススコア変遷取得, 最新は「現在」と一致するので除去している
    logs = list_skill_class_score_logs(user, skill_class, date_from, date_end)
    {latest_log, logs} = List.pop_at(logs, -1)
    prev_log = Enum.at(logs, -1, %{})
    prev_date = Map.get(prev_log, :date)
    prev_value = Map.get(prev_log, :percentage)

    # 直前値がないとき、最新値が存在するならば点を打つために過去から引いてくる
    prev_value =
      if latest_log do
        prev_value ||
          HistoricalSkillScores.get_historical_skill_class_score_percentage(
            user,
            skill_class,
            date_from
          ) ||
          0
      end

    date_percentage =
      logs
      |> Enum.reduce(%{}, fn log, acc ->
        Map.update(acc, log.date, [log.percentage], &(&1 ++ [log.percentage]))
      end)
      |> Map.new(fn {date, values} -> {date, List.last(values)} end)

    # データ集約
    # - prev_dateまでは日付単位で拾っていく
    # - prev_date以降はnil詰めし直前スコアとしてprev_valueを入れている
    #   - 言い換えると、prev_dateにあたるところには値をいれず、最後になるように入れている
    dates_before_prev = Date.range(date_from, Date.add(prev_date || date_end, -1), 1)
    dates_after_prev = Date.range(Date.add(prev_date || date_end, 1), date_end, 1)

    values_before_prev = Enum.map(dates_before_prev, &Map.get(date_percentage, &1))

    values_after_prev =
      Enum.map(dates_after_prev, fn _ -> nil end)
      |> Kernel.++([prev_value])

    values_before_prev ++ values_after_prev
  end
end
