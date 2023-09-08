defmodule Bright.Repo.Migrations.CreateNotificationOfficialTeams do
  use Ecto.Migration

  def change do
    create table(:notification_official_teams) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :to_user_id, references(:users, on_delete: :nothing), null: false
      add :message, :string
      add :detail, :text
      add :participation, :boolean, default: false, null: false

      timestamps()
    end

    create index(:notification_official_teams, [:to_user_id])
  end
end
