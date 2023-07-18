defmodule Bright.Repo.Migrations.AddIndexUserIdUserOnboardings do
  use Ecto.Migration

  def change do
    drop index(:user_onboardings, [:user_id])
    create unique_index(:user_onboardings, [:user_id])
  end
end
