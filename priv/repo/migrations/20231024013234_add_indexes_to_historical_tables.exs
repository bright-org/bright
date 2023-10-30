defmodule Bright.Repo.Migrations.AddIndexesToHistoricalTables do
  use Ecto.Migration

  def change do
    # Skill structures
    create index(:historical_skill_classes, [:skill_panel_id])
    create index(:historical_skill_classes, [:locked_date])

    create index(:historical_skill_units, [:locked_date])

    create index(:historical_skill_categories, [:historical_skill_unit_id])

    create index(:historical_skills, [:historical_skill_category_id])

    create index(:historical_skill_class_units, [:historical_skill_class_id])
    create index(:historical_skill_class_units, [:historical_skill_unit_id])

    # Scores
    create index(:historical_skill_scores, [:user_id])
    create index(:historical_skill_scores, [:historical_skill_id])

    create index(:historical_skill_class_scores, [:user_id])
    create index(:historical_skill_class_scores, [:historical_skill_class_id])

    create index(:historical_skill_unit_scores, [:user_id])
    create index(:historical_skill_unit_scores, [:historical_skill_unit_id])

    create index(:historical_career_field_scores, [:user_id])
    create index(:historical_career_field_scores, [:career_field_id])
  end
end
