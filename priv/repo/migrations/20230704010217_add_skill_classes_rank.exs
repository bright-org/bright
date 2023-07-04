defmodule Bright.Repo.Migrations.AddSkillClassesRank do
  use Ecto.Migration

  def up do
    alter table(:skill_classes) do
      add :rank, :integer, null: false, default: 1
    end

    # 初期化用SQL
    # - すでに存在するレコードが続くunique_index作成時にエラーになるため対応
    execute "
    WITH rankings AS (
      SELECT id,
        ROW_NUMBER() OVER(PARTITION BY skill_panel_id ORDER BY id) AS new_rank
      FROM skill_classes
    )
    UPDATE skill_classes sc
    SET rank = r.new_rank
    FROM rankings r
    WHERE sc.id = r.id
    "

    drop index(:skill_classes, [:skill_panel_id])
    create unique_index(:skill_classes, [:skill_panel_id, :rank])
  end

  def down do
    drop unique_index(:skill_classes, [:skill_panel_id, :rank])
    create index(:skill_classes, [:skill_panel_id])

    alter table(:skill_classes) do
      remove :rank
    end
  end
end
