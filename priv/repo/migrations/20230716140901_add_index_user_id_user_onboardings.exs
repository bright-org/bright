defmodule Bright.Repo.Migrations.AddIndexUserIdUserOnboardings do
  use Ecto.Migration

  def change do
    drop_if_exists index(:user_onboardings, [:user_id])
    create unique_index(:user_onboardings, [:user_id])
  end
end
