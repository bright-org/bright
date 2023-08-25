defmodule Bright.Repo.Migrations.CreateNotificationOperations do
  use Ecto.Migration

  def change do
    create table(:notification_operations) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :message, :string
      add :detail, :text

      timestamps()
    end
  end
end
