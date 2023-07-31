defmodule Bright.Repo.Migrations.RemoveLockedDateFromSkillPanels do
  use Ecto.Migration

  def change do
    alter table(:skill_panels) do
      remove :locked_date, :date
    end
  end
end
