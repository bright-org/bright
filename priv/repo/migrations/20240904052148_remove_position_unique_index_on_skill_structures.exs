defmodule Bright.Repo.Migrations.RemovePositionUniqueIndexOnSkillStructures do
  @moduledoc """
  ドラフトツール側でpositionをユニークにしているため、
  そのデータをコピーするだけの本番スキルテーブル側からユニーク制約を外しています。
  （ドラフトから本番への即時反映の処理の複雑さが増すため）
  """

  use Ecto.Migration

  def up do
    # スキルカテゴリ
    drop unique_index(:skill_categories, [:skill_unit_id, :position])
    create index(:skill_categories, [:skill_unit_id, :position])

    # スキル
    drop unique_index(:skills, [:skill_category_id, :position])
    create index(:skills, [:skill_category_id, :position])

    # スキルクラスユニット
    # そもそも元インデックスが不適当だったので合わせて修正
    drop unique_index(:skill_class_units, [:skill_class_id, :skill_unit_id, :position])
    create index(:skill_class_units, [:skill_class_id, :position])
    create index(:skill_class_units, [:skill_unit_id])
  end

  def down do
    # スキルカテゴリ
    drop index(:skill_categories, [:skill_unit_id, :position])
    create unique_index(:skill_categories, [:skill_unit_id, :position])

    # スキル
    drop index(:skills, [:skill_category_id, :position])
    create unique_index(:skills, [:skill_category_id, :position])

    # スキルクラスユニット
    # そもそも元インデックスが不適当だったので合わせて修正
    drop index(:skill_class_units, [:skill_class_id, :position])
    drop index(:skill_class_units, [:skill_unit_id])
    create unique_index(:skill_class_units, [:skill_class_id, :skill_unit_id, :position])
  end
end
