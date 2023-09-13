defmodule Bright.Repo.Migrations.CreateNotificationCommunities do
  use Ecto.Migration

  def change do
    create table(:notification_communities) do
      add :from_user_id, references(:users, on_delete: :nothing), null: false
      add :message, :string
      add :detail, :text

      timestamps()
    end
  end
end
