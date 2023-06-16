defmodule Bright.Repo.Migrations.CreateSkillPanels do
  use Ecto.Migration

  def change do
    # TODO: idを連番じゃないものに変える
    create table(:skill_panels) do
      add :locked_date, :date
      add :name, :string, null: false

      timestamps()
    end

    create index(:skill_panels, [:locked_date])
  end
end
