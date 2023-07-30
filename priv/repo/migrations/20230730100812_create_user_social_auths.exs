defmodule Bright.Repo.Migrations.CreateUserSocialAuths do
  use Ecto.Migration

  def change do
    create table(:user_social_auths) do
      add :provider, :string
      add :identifier, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:user_social_auths, [:user_id])
  end
end
