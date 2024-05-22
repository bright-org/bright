defmodule Bright.Repo.Migrations.ChangeIncomeIntegerToFloat do
  use Ecto.Migration

  def up do
    alter table(:employments) do
      modify :desired_income, :decimal
      modify :income, :decimal
    end

    alter table(:coordinations) do
      modify :desired_income, :decimal
    end

    alter table(:interviews) do
      modify :desired_income, :decimal
    end

    alter table(:recruitment_stock_users) do
      modify :desired_income, :decimal
    end

    alter table(:user_job_profiles) do
      modify :desired_income, :decimal
    end
  end

  def down do
    alter table(:employments) do
      modify :desired_income, :integer
      modify :income, :integer
    end

    alter table(:coordinations) do
      modify :desired_income, :integer
    end

    alter table(:interviews) do
      modify :desired_income, :integer
    end

    alter table(:recruitment_stock_users) do
      modify :desired_income, :integer
    end

    alter table(:user_job_profiles) do
      modify :desired_income, :integer
    end
  end
end
