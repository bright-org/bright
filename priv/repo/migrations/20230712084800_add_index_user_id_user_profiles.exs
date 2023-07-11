defmodule Bright.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create unique_index(:user_profiles, [:user_id])
  end
end
