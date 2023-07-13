defmodule Bright.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :to_user_id, references(:users, on_delete: :nothing), null: false
      add :icon_type, :string, null: false
      add :message, :string, null: false
      add :type, :string, null: false
      add :url, :string
      add :read_at, :naive_datetime

      timestamps()
    end

    create index(:notifications, [:to_user_id])
    create index(:notifications, [:type])
    create index(:notifications, [:read_at])
  end
end
