defmodule Bright.Repo.Migrations.AddSkillPanelNameIncomeToRecruitmentStockUsers do
  use Ecto.Migration

  def change do
    alter table(:recruitment_stock_users) do
      add :skill_panel, :string, default: ""
      add :desired_income, :integer, default: 0
    end
  end
end
