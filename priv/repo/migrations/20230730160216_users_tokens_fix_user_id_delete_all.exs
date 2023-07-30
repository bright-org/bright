defmodule Bright.Repo.Migrations.UsersTokensFixUserIdDeleteAll do
  use Ecto.Migration

  def change do
    alter table(:users_tokens) do
      remove :user_id
      add :user_id, references(:users, on_delete: :nothing), null: false
    end
  end
end
