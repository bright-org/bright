defmodule Bright.Repo.Migrations.CreateJobSkillPanels do
  use Ecto.Migration

  def change do
    create table(:job_skill_panels) do
      add :job_id, references(:jobs, on_delete: :nothing)
      add :skill_panel_id, references(:skill_panels, on_delete: :nothing)

      timestamps()
    end

    create index(:job_skill_panels, [:job_id])
    create index(:job_skill_panels, [:skill_panel_id])
  end
end
