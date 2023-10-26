defmodule Bright.Repo.Migrations.DeleteNotifications do
  use Ecto.Migration

  def up do
    drop_if_exists table(:notifications)
  end

  # Bright.Repo.Migrations.CreateNotifications
  def down do
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
  end
end
