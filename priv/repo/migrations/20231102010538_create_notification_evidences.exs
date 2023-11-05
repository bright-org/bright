defmodule Bright.Repo.Migrations.CreateNotificationEvidences do
  use Ecto.Migration

  def change do
    create table(:notification_evidences) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :to_user_id, references(:users, on_delete: :nothing), null: false
      add :message, :string
      add :url, :string

      timestamps()
    end

    create index(:notification_evidences, [:to_user_id])
  end
end
