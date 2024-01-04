defmodule Bright.Repo.Migrations.CreateUserNotifications do
  use Ecto.Migration

  def change do
    create table(:user_notifications) do
      add :user_id, references(:users, on_delete: :nothing)
      add :last_viewed_at, :naive_datetime, null: false

      timestamps()
    end

    create index(:user_notifications, [:user_id])
    create index(:notification_operations, [:updated_at])
    create index(:notification_communities, [:updated_at])
    create index(:notification_evidences, [:to_user_id, :updated_at])
  end
end
