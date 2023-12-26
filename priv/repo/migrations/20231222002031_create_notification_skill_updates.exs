defmodule Bright.Repo.Migrations.CreateNotificationSkillUpdates do
  use Ecto.Migration

  def change do
    create table(:notification_skill_updates) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :to_user_id, references(:users, on_delete: :nothing), null: false
      add :message, :string
      add :url, :string

      timestamps()
    end

    create index(:notification_skill_updates, [:to_user_id, :updated_at])
  end
end
