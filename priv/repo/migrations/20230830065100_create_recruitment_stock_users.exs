defmodule Bright.Repo.Migrations.CreateRecruitmentStockUsers do
  use Ecto.Migration

  def change do
    create table(:recruitment_stock_users) do
      add :recruiter_id, references(:users, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end
  end
end
