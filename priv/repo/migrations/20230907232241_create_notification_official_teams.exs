defmodule Bright.Repo.Migrations.CreateNotificationOfficialTeams do
  use Ecto.Migration

  def change do
    create table(:notification_official_teams) do
      add :from_user_id, :uuid
      add :to_user_id, :uuid
      add :message, :string
      add :detail, :text
      add :participation, :boolean, default: false, null: false

      timestamps()
    end
  end
end
