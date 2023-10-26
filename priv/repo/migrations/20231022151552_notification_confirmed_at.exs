defmodule Bright.Repo.Migrations.NotificationConfirmedAt do
  use Ecto.Migration

  def change do
    alter table(:notification_operations) do
      add :confirmed_at, :naive_datetime
    end

    alter table(:notification_communities) do
      add :confirmed_at, :naive_datetime
    end

    create index(:notification_operations, [:confirmed_at])
    create index(:notification_communities, [:confirmed_at])
  end
end
