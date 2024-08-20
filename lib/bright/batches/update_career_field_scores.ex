defmodule Bright.Batches.UpdateCareerFieldScores do
  @moduledoc """
  キャリアフィールドスコアを更新するバッチ。

  キャリアフィールドスコアは、大規模な集計のため、スキルスコア更新（画面操作）の度には更新せずにバッチによって更新する。
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerFields.CareerField
  alias Bright.Jobs.Job
  alias Bright.SkillPanels.SkillPanel
  alias Bright.Accounts.User
  alias Bright.SkillScores.{SkillScore, CareerFieldScore}

  def call do
    career_fields = list_career_fields()

    # 処理効率化のために先に辞書生成している. 2つある
    # - キャリアフィールドからスキルパネル
    # - スキルパネルからスキル
    career_field_skill_panel_ids = map_skill_panel_by_career_field(career_fields)
    skill_panel_skill_ids = map_skill_by_skill_panel()

    list_users()
    |> Enum.each(fn user ->
      run_each_user(
        user,
        career_fields,
        career_field_skill_panel_ids,
        skill_panel_skill_ids
      )
    end)
  end

  # ユーザー単位のキャリアフィールドスコア更新処理
  # - スキルスコアを取得していないユーザー（登録後未操作）は処理対象から除外している
  defp run_each_user(user, career_fields, career_field_skill_panel_ids, skill_panel_skill_ids) do
    user_career_field_skill_ids =
      map_skill_ids_on_user(
        user,
        career_fields,
        career_field_skill_panel_ids,
        skill_panel_skill_ids
      )

    dict_counts =
      Map.new(career_fields, fn career_field ->
        skill_ids = Map.get(user_career_field_skill_ids, career_field.id) || []
        skills_count = Enum.count(skill_ids)
        high_skills_count = count_high_skills(user, skill_ids)
        percentage = if(skills_count == 0, do: 0.0, else: 100 * high_skills_count / skills_count)

        {career_field, {high_skills_count, percentage}}
      end)

    # 更新対象判定
    # NOTE: スキルスコア取得後に「全て」未取得に戻すケースも厳密には更新対象だが運用上起こりにくくチェックを省いている
    max_percentage =
      Enum.map(dict_counts, fn {_, {_, percentage}} -> percentage end) |> Enum.max()

    upsert_required? = max_percentage > 0

    upsert_required? &&
      upsert_career_field_scores(user, career_fields, dict_counts, max_percentage)
  end

  def upsert_career_field_scores(user, career_fields, dict_counts, max_percentage) do
    scores =
      career_fields
      |> Enum.map(fn career_field ->
        {high_skills_count, percentage} = Map.get(dict_counts, career_field) || {0, 0.0}
        relative_percentage = 100 * (percentage / max_percentage)

        %{
          id: Ecto.ULID.generate(),
          user_id: user.id,
          career_field_id: career_field.id,
          high_skills_count: high_skills_count,
          percentage: relative_percentage,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    placeholders = %{timestamp: timestamp}

    Repo.insert_all(
      CareerFieldScore,
      scores,
      placeholders: placeholders,
      on_conflict: {
        :replace,
        [:high_skills_count, :percentage, :updated_at]
      },
      conflict_target: [:user_id, :career_field_id]
    )
  end

  # score: highのレコード数取得
  defp count_high_skills(user, skill_ids) do
    from(
      skill_score in SkillScore,
      where: skill_score.user_id == ^user.id,
      where: skill_score.skill_id in ^skill_ids,
      where: skill_score.score == :high
    )
    |> Repo.aggregate(:count)
  end

  # userのキャリアフィールドごとの対象スキル参照を返す
  # スキルパネルではなくスキルレベルで見ることで共有スキルも考慮している
  defp map_skill_ids_on_user(
         user,
         career_fields,
         career_field_skill_panel_ids,
         skill_panel_skill_ids
       ) do
    user_skill_panel_ids = Enum.map(user.user_skill_panels, & &1.skill_panel_id)

    career_fields
    |> Map.new(fn career_field ->
      skill_panel_ids = Map.get(career_field_skill_panel_ids, career_field.id) || []
      skill_panel_ids = intersection(skill_panel_ids, user_skill_panel_ids)
      skill_ids = Enum.flat_map(skill_panel_ids, &(Map.get(skill_panel_skill_ids, &1) || []))

      {career_field.id, Enum.uniq(skill_ids)}
    end)
  end

  # 対象となるユーザーを取得
  defp list_users do
    from(
      user in User,
      where: not is_nil(user.confirmed_at),
      join: usp in assoc(user, :user_skill_panels),
      preload: [user_skill_panels: usp]
    )
    |> Repo.all()
  end

  # スキルパネルに紐づくスキル参照の準備
  defp map_skill_by_skill_panel do
    from(
      panel in SkillPanel,
      join: classes in assoc(panel, :skill_classes),
      join: units in assoc(classes, :skill_units),
      join: categories in assoc(units, :skill_categories),
      join: skills in assoc(categories, :skills),
      preload: [
        skill_classes:
          {classes,
           [
             skill_units:
               {units,
                [
                  skill_categories:
                    {categories,
                     [
                       skills: skills
                     ]}
                ]}
           ]}
      ]
    )
    |> Repo.all()
    |> Map.new(fn skill_panel ->
      skill_ids =
        skill_panel.skill_classes
        |> Enum.flat_map(& &1.skill_units)
        |> Enum.flat_map(& &1.skill_categories)
        |> Enum.flat_map(& &1.skills)
        |> Enum.map(& &1.id)

      {skill_panel.id, skill_ids}
    end)
  end

  # キャリアフィールドに紐づくスキルパネル参照の準備
  defp map_skill_panel_by_career_field(career_fields) do
    dict_skill_panels_job = map_jobs()

    career_fields
    |> Map.new(fn career_field ->
      skill_panel_ids =
        career_field.jobs
        |> Enum.flat_map(&(Map.get(dict_skill_panels_job, &1.id) || []))
        |> Enum.uniq()
        |> Enum.map(& &1.id)

      {career_field.id, skill_panel_ids}
    end)
  end

  defp list_career_fields do
    from(
      career_field in CareerField,
      join: jobs in assoc(career_field, :jobs),
      preload: [jobs: jobs]
    )
    |> Repo.all()
  end

  defp map_jobs do
    from(
      job in Job,
      join: skill_panels in assoc(job, :skill_panels),
      preload: [skill_panels: skill_panels]
    )
    |> Repo.all()
    |> Map.new(&{&1.id, &1.skill_panels})
  end

  defp intersection(list_1, list_2) do
    MapSet.intersection(MapSet.new(list_1), MapSet.new(list_2))
  end
end
