defmodule Bright.Repo.Migrations.ReanmeNameToSkillPanelNameAtInterview do
  use Ecto.Migration

  def change do
    alter table(:interviews) do
      add :skill_panel_name, :string
      add :desired_income, :integer
      remove :name
    end
  end
end
