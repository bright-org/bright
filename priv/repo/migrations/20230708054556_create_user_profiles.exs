defmodule Bright.Repo.Migrations.CreateUserProfiles do
  use Ecto.Migration

  def change do
    create table(:user_profiles) do
      add :user_id, references(:users, on_delete: :nothing)
      add :title, :string
      add :detail, :string
      add :icon_file_path, :string
      add :twitter_url, :string
      add :facebook_url, :string
      add :github_url, :string

      timestamps()
    end
  end
end
