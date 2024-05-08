defmodule Bright.Repo.Migrations.ChatUserIsRead do
  use Ecto.Migration

  def change do
    alter table(:chat_users) do
      add :is_read, :boolean, default: true, null: false
    end
  end
end
