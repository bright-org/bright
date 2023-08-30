defmodule Bright.Repo.Migrations.CreateRecruitmentStockUsers do
  use Ecto.Migration

  def change do
    create table(:recruitment_stock_users) do
      add :recruiter_id, :uuid
      add :user_id, :uuid

      timestamps()
    end
  end
end
