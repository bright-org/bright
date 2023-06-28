defmodule Bright.Repo.Migrations.CreateSkillPanels do
  use Ecto.Migration

  def change do
    create table(:skill_panels) do
      add :locked_date, :date
      add :name, :string, null: false

      timestamps()
    end

    create index(:skill_panels, [:locked_date])
  end
end
