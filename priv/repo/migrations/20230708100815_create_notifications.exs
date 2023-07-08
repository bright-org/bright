defmodule Bright.Repo.Migrations.CreateNotifications do
  use Ecto.Migration

  def change do
    create table(:notifications) do
      add :from_user_id, references(:users, on_delete: :nothing)
      add :to_user_id, references(:users, on_delete: :nothing)
      add :icon_type, :string
      add :message, :string
      add :type, :string
      add :url, :string
      add :read_at, :naive_datetime

      timestamps()
    end

    create index(:notifications, [:to_user_id, :type, :read_at])
  end
end
