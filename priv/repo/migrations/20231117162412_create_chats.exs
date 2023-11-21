defmodule Bright.Repo.Migrations.CreateChats do
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :relation_type, :string
      add :relation_id, :uuid
      add :owner_user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:chats, [:owner_user_id])
  end
end
