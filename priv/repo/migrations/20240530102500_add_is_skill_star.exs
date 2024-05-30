defmodule Bright.Repo.Migrations.AddIsSkillStar do
  use Ecto.Migration
  def change do
    alter table(:team_member_users) do
      add :is_skill_star, :boolean, default: false, null: false
    end
  end
end
