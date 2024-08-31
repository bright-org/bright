defmodule Bright.DraftSkillPanels.Release do
  @moduledoc """
  スキルパネル単位でドラフトを本番系に反映させる処理
  """

  import Ecto.Query, warn: false

  alias Bright.SkillScores
  alias Bright.Repo

  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillUnits
  alias Bright.SkillUnits.SkillClassUnit
  alias Bright.SkillUnits.SkillUnit
  alias Bright.SkillUnits.SkillCategory
  alias Bright.SkillUnits.Skill

  alias Bright.DraftSkillPanels.DraftSkillClass
  alias Bright.DraftSkillUnits.DraftSkillClassUnit
  alias Bright.DraftSkillUnits.DraftSkill

  alias BrightWeb.TimelineHelper

  @doc """
  反映処理

  - 指定スキルパネルに属するスキルクラス以下のデータが対象になる
    - スキルユニットを共有しているケースでは、指定スキルパネルを越えて影響する
  - 更新処理は大きく2つに分かれる
    - スキル構造反映
    - 影響対象のユーザースコア再計算（スキルクラス、スキルユニット）
      - キャリアフィールドスコアは日一回のバッチ処理に任せる
      - NOTE: 再計算に係る時間はユーザー数に依存するため、増えた場合には何かしらバッチ処理に落とす必要がある
  """
  def commit(skill_panel) do
    {:ok, focused_skill_classes} = commit_structures(skill_panel)
    SkillScores.re_aggregate_scores(focused_skill_classes)
  end

  defp commit_structures(skill_panel) do
    # 指定スキルパネルのスキルクラス以下のデータを生成、更新、削除している
    # - スキルクラスに関しては削除はない（スキルパネルごと削除がそれにあたる）
    # - 返値は、後続処理の便宜上、スコア変動が発生する可能性があるスキルユニット一覧としている

    # 移動前後を含めて考慮するため、最小単位のスキルから、ドラフトと本番の指定スキルパネルの全対象データを得ている
    all_target_skill_trace_ids = list_target_skill_trace_ids(skill_panel)

    # 対象データの、ドラフトと本番のそれぞれのデータを取得している（移動前後があるため指定スキルパネル以外に属するものも含む）
    d_skill_classes = list_draft_skill_classes(skill_panel)
    c_skill_classes = list_skill_classes(skill_panel)

    {d_skills, d_skill_categories, d_skill_units} =
      list_draft_skill_structures(all_target_skill_trace_ids)

    {c_skills, c_skill_categories, c_skill_units} =
      list_skill_structures(all_target_skill_trace_ids)

    #   本番データは、移動時に関連紐づけがあるため必要なデータをさらに集めている
    c_skill_categories =
      (c_skill_categories ++ list_skill_categories_by_tarce_id(d_skill_categories)) |> Enum.uniq()

    c_skill_units = (c_skill_units ++ list_skill_units_by_tarce_id(d_skill_units)) |> Enum.uniq()

    d_skill_class_units = list_draft_skill_class_units(d_skill_units)
    c_skill_class_units = list_skill_class_units(c_skill_units)

    Repo.transaction(fn ->
      # スキルクラスの更新
      {_count, skill_classes} = commit_skill_classes(d_skill_classes, c_skill_classes)

      # スキルユニットの更新, 更新後のskill_unitsは下階層の関連付けに使用する
      {_count, skill_units} = commit_skill_units(d_skill_units, c_skill_units)
      skill_units = Enum.uniq_by(skill_units ++ c_skill_units, & &1.trace_id)

      # スキルカテゴリの更新, 更新後のskill_categoriesは下階層の関連付けに使用する
      {_count, skill_categories} =
        commit_skill_categories(
          d_skill_categories,
          c_skill_categories,
          skill_units,
          d_skill_units
        )

      skill_categories = Enum.uniq_by(skill_categories ++ c_skill_categories, & &1.trace_id)

      # スキルの更新
      {_count, _skills} = commit_skills(d_skills, c_skills, skill_categories, d_skill_categories)

      # スキルクラス-スキルユニット関連
      # 移動を考慮すると指定スキルパネル以外に紐づくスキルクラスも必要のため再取得
      d_skill_classes = list_draft_skill_classes(d_skill_units)
      skill_classes = Enum.uniq(list_skill_classes(d_skill_classes) ++ skill_classes)

      {_count, _skill_class_unit} =
        commit_skill_class_units(
          d_skill_class_units,
          c_skill_class_units,
          skill_classes,
          d_skill_classes,
          skill_units,
          d_skill_units
        )

      # 使われていないデータを削除する
      # 外部制約があるので作成とは逆順に行う
      delete_skill_class_units(d_skill_class_units, c_skill_class_units)
      delete_skills(d_skills, c_skills)
      delete_skill_categories(d_skill_categories, c_skill_categories)
      delete_skill_units(d_skill_units, c_skill_units)

      # スキルスコア更新が必要な可能性のあるスキルクラスを一式返す
      Enum.uniq(skill_classes ++ c_skill_classes)
    end)
  end

  defp commit_skill_classes(d_skill_classes, c_skill_classes) do
    # 作成と更新をupsertで対応する
    id_by_trace_id = Map.new(c_skill_classes, &{&1.trace_id, &1.id})
    placeholders = gen_upsert_placeholders([:timestamp, :locked_date])

    attrs_list =
      Enum.map(d_skill_classes, fn d_skill_class ->
        id = Map.get(id_by_trace_id, d_skill_class.trace_id, Ecto.ULID.generate())

        %{
          id: id,
          trace_id: d_skill_class.trace_id,
          name: d_skill_class.name,
          class: d_skill_class.class,
          skill_panel_id: d_skill_class.skill_panel_id,
          locked_date: {:placeholder, :locked_date},
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    # idが同じものは更新、その他は新規作成
    Repo.insert_all(
      SkillClass,
      attrs_list,
      placeholders: placeholders,
      on_conflict: {:replace, [:name, :updated_at]},
      conflict_target: [:id],
      returning: true
    )
  end

  defp commit_skill_units(d_skill_units, c_skill_units) do
    # 作成と更新をupsertで対応する
    id_by_trace_id = Map.new(c_skill_units, &{&1.trace_id, &1.id})
    placeholders = gen_upsert_placeholders([:timestamp, :locked_date])

    attrs_list =
      Enum.map(d_skill_units, fn d_skill_unit ->
        id = Map.get(id_by_trace_id, d_skill_unit.trace_id, Ecto.ULID.generate())

        %{
          id: id,
          trace_id: d_skill_unit.trace_id,
          name: d_skill_unit.name,
          locked_date: {:placeholder, :locked_date},
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    # idが同じものは更新、その他は新規作成
    Repo.insert_all(
      SkillUnit,
      attrs_list,
      placeholders: placeholders,
      on_conflict: {:replace, [:name, :updated_at]},
      conflict_target: [:id],
      returning: true
    )
  end

  defp commit_skill_categories(d_skill_categories, c_skill_categories, skill_units, d_skill_units) do
    # 作成と更新をupsertで対応する
    id_by_trace_id = Map.new(c_skill_categories, &{&1.trace_id, &1.id})
    placeholders = gen_upsert_placeholders([:timestamp])

    # 親スキルユニットをtrace_id経由で特定できるように辞書を生成
    parent_trace_id_by_draft_parent_id = Map.new(d_skill_units, &{&1.id, &1.trace_id})
    skill_unit_id_by_trace_id = Map.new(skill_units, &{&1.trace_id, &1.id})

    attrs_list =
      Enum.map(d_skill_categories, fn d_skill_category ->
        id = Map.get(id_by_trace_id, d_skill_category.trace_id, Ecto.ULID.generate())

        parent_trace_id =
          Map.get(parent_trace_id_by_draft_parent_id, d_skill_category.draft_skill_unit_id)

        skill_unit_id = Map.get(skill_unit_id_by_trace_id, parent_trace_id)

        %{
          id: id,
          trace_id: d_skill_category.trace_id,
          name: d_skill_category.name,
          position: d_skill_category.position,
          skill_unit_id: skill_unit_id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    # idが同じものは更新、その他は新規作成
    Repo.insert_all(
      SkillCategory,
      attrs_list,
      placeholders: placeholders,
      on_conflict: {:replace, [:name, :position, :skill_unit_id, :updated_at]},
      conflict_target: [:id],
      returning: true
    )
  end

  defp commit_skills(d_skills, c_skills, skill_categories, d_skill_categories) do
    # 作成と更新をupsertで対応する
    id_by_trace_id = Map.new(c_skills, &{&1.trace_id, &1.id})
    placeholders = gen_upsert_placeholders([:timestamp])

    # 親スキルカテゴリをtrace_id経由で特定できるように辞書を生成
    parent_trace_id_by_draft_parent_id = Map.new(d_skill_categories, &{&1.id, &1.trace_id})
    skill_category_id_by_trace_id = Map.new(skill_categories, &{&1.trace_id, &1.id})

    attrs_list =
      Enum.map(d_skills, fn d_skill ->
        id = Map.get(id_by_trace_id, d_skill.trace_id, Ecto.ULID.generate())

        parent_trace_id =
          Map.get(parent_trace_id_by_draft_parent_id, d_skill.draft_skill_category_id)

        skill_category_id = Map.get(skill_category_id_by_trace_id, parent_trace_id)

        %{
          id: id,
          trace_id: d_skill.trace_id,
          name: d_skill.name,
          position: d_skill.position,
          skill_category_id: skill_category_id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    # idが同じものは更新、その他は新規作成
    Repo.insert_all(
      Skill,
      attrs_list,
      placeholders: placeholders,
      on_conflict: {:replace, [:name, :position, :skill_category_id, :updated_at]},
      conflict_target: [:id],
      returning: true
    )
  end

  defp commit_skill_class_units(
         d_skill_class_units,
         c_skill_class_units,
         skill_classes,
         d_skill_classes,
         skill_units,
         d_skill_units
       ) do
    # 作成と更新をupsertで対応する
    id_by_trace_id = Map.new(c_skill_class_units, &{&1.trace_id, &1.id})
    placeholders = gen_upsert_placeholders([:timestamp])

    # 関連をtrace_id経由で特定できるように辞書を生成
    skill_class_trace_id_by_draft_id = Map.new(d_skill_classes, &{&1.id, &1.trace_id})
    skill_class_id_by_trace_id = Map.new(skill_classes, &{&1.trace_id, &1.id})
    skill_unit_trace_id_by_draft_id = Map.new(d_skill_units, &{&1.id, &1.trace_id})
    skill_unit_id_by_trace_id = Map.new(skill_units, &{&1.trace_id, &1.id})

    attrs_list =
      Enum.map(d_skill_class_units, fn d_skill_class_unit ->
        id = Map.get(id_by_trace_id, d_skill_class_unit.trace_id, Ecto.ULID.generate())

        skill_class_trace_id =
          Map.get(skill_class_trace_id_by_draft_id, d_skill_class_unit.draft_skill_class_id)

        skill_class_id = Map.get(skill_class_id_by_trace_id, skill_class_trace_id)

        skill_unit_trace_id =
          Map.get(skill_unit_trace_id_by_draft_id, d_skill_class_unit.draft_skill_unit_id)

        skill_unit_id = Map.get(skill_unit_id_by_trace_id, skill_unit_trace_id)

        %{
          id: id,
          trace_id: d_skill_class_unit.trace_id,
          position: d_skill_class_unit.position,
          skill_class_id: skill_class_id,
          skill_unit_id: skill_unit_id,
          inserted_at: {:placeholder, :timestamp},
          updated_at: {:placeholder, :timestamp}
        }
      end)

    # idが同じものは更新、その他は新規作成
    Repo.insert_all(
      SkillClassUnit,
      attrs_list,
      placeholders: placeholders,
      on_conflict: {:replace, [:position, :skill_class_id, :skill_unit_id, :updated_at]},
      conflict_target: [:id],
      returning: true
    )
  end

  defp delete_skills(d_skills, c_skills) do
    list_deleted_items(d_skills, c_skills)
    |> Enum.each(&SkillUnits.delete_skill/1)
  end

  def delete_skill_categories(d_skill_categories, c_skill_categories) do
    list_deleted_items(d_skill_categories, c_skill_categories)
    |> Enum.each(&SkillUnits.delete_skill_category/1)
  end

  def delete_skill_units(d_skill_units, c_skill_units) do
    list_deleted_items(d_skill_units, c_skill_units)
    |> Enum.each(&SkillUnits.delete_skill_unit/1)
  end

  def delete_skill_class_units(d_skill_class_units, c_skill_class_units) do
    list_deleted_items(d_skill_class_units, c_skill_class_units)
    |> Enum.each(&SkillUnits.delete_skill_class_unit/1)
  end

  defp list_target_skill_trace_ids(skill_panel) do
    # 考慮すべき全データの洗い出し
    d_trace_ids = list_draft_skill_trace_ids_on_skill_panel(skill_panel)
    trace_ids = list_skill_trace_ids_on_skill_panel(skill_panel)

    Enum.uniq(d_trace_ids ++ trace_ids)
  end

  defp list_draft_skill_trace_ids_on_skill_panel(skill_panel) do
    from(
      q in DraftSkillClass,
      where: q.skill_panel_id == ^skill_panel.id,
      join: dsu in assoc(q, :draft_skill_units),
      join: dsc in assoc(dsu, :draft_skill_categories),
      join: dss in assoc(dsc, :draft_skills),
      select: dss.trace_id
    )
    |> Repo.all()
  end

  defp list_skill_trace_ids_on_skill_panel(skill_panel) do
    from(
      q in SkillClass,
      where: q.skill_panel_id == ^skill_panel.id,
      join: su in assoc(q, :skill_units),
      join: sc in assoc(su, :skill_categories),
      join: ss in assoc(sc, :skills),
      select: ss.trace_id
    )
    |> Repo.all()
  end

  defp list_draft_skill_structures(trace_ids) do
    from(
      q in DraftSkill,
      where: q.trace_id in ^trace_ids,
      join: dsc in assoc(q, :draft_skill_category),
      join: dsu in assoc(dsc, :draft_skill_unit),
      select: {q, dsc, dsu}
    )
    |> Repo.all()
    |> reduce_skill_structures()
  end

  defp list_skill_structures(trace_ids) do
    from(
      q in Skill,
      where: q.trace_id in ^trace_ids,
      join: sc in assoc(q, :skill_category),
      join: su in assoc(sc, :skill_unit),
      select: {q, sc, su}
    )
    |> Repo.all()
    |> reduce_skill_structures()
  end

  defp list_skill_categories_by_tarce_id(d_skill_categories) do
    trace_ids = Enum.map(d_skill_categories, & &1.trace_id)

    from(q in SkillCategory, where: q.trace_id in ^trace_ids)
    |> Repo.all()
  end

  defp list_skill_units_by_tarce_id(d_skill_units) do
    trace_ids = Enum.map(d_skill_units, & &1.trace_id)

    from(q in SkillUnit, where: q.trace_id in ^trace_ids)
    |> Repo.all()
  end

  defp list_draft_skill_classes(%{id: skill_panel_id}) do
    from(q in DraftSkillClass, where: q.skill_panel_id == ^skill_panel_id)
    |> Repo.all()
  end

  defp list_draft_skill_classes(d_skill_units) do
    d_skill_unit_ids = Enum.map(d_skill_units, & &1.id)

    from(
      q in DraftSkillClass,
      join: dscu in assoc(q, :draft_skill_class_units),
      where: dscu.draft_skill_unit_id in ^d_skill_unit_ids,
      distinct: true
    )
    |> Repo.all()
  end

  defp list_skill_classes(%{id: skill_panel_id}) do
    from(q in SkillClass, where: q.skill_panel_id == ^skill_panel_id)
    |> Repo.all()
  end

  defp list_skill_classes(d_skill_classes) do
    trace_ids = Enum.map(d_skill_classes, & &1.trace_id)

    from(q in SkillClass, where: q.trace_id in ^trace_ids)
    |> Repo.all()
  end

  defp list_draft_skill_class_units(d_skill_units) do
    d_skill_unit_ids = Enum.map(d_skill_units, & &1.id)

    from(q in DraftSkillClassUnit, where: q.draft_skill_unit_id in ^d_skill_unit_ids)
    |> Repo.all()
  end

  defp list_skill_class_units(c_skill_units) do
    c_skill_unit_ids = Enum.map(c_skill_units, & &1.id)

    from(q in SkillClassUnit, where: q.skill_unit_id in ^c_skill_unit_ids)
    |> Repo.all()
  end

  defp gen_upsert_placeholders(list) do
    Enum.reduce(list, %{}, fn key, acc ->
      Map.put(acc, key, gen_upsert_value(key))
    end)
  end

  defp gen_upsert_value(:timestamp) do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
  end

  defp gen_upsert_value(:locked_date) do
    # 1つ前のスキルパネル更新日相当日付としている
    # - 例外的な手動更新のため、あくまで前回更新日にあった体にしないとその他機能での参照に不具合が起きる
    timeline = TimelineHelper.get_current()
    TimelineHelper.get_shift_date_from_date(timeline.future_date, -1)
  end

  defp reduce_skill_structures(list) do
    # {skill, category, unit}のlistを{skills, categories, units}の形に変換
    list
    |> Enum.reduce({[], [], []}, fn
      {}, acc ->
        acc

      {skill, category, unit}, {skills, categories, units} ->
        {[skill] ++ skills, [category] ++ categories, [unit] ++ units}
    end)
    |> then(fn {skills, categories, units} ->
      {skills, Enum.uniq(categories), Enum.uniq(units)}
    end)
  end

  defp list_deleted_items(d_items, c_items) do
    # currentにありdraftにない(=ドラフトで消えている)ものが消す対象
    d_trace_ids = Enum.map(d_items, & &1.trace_id)
    Enum.filter(c_items, &(&1.trace_id not in d_trace_ids))
  end
end
