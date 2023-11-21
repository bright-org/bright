defmodule Bright.Repo.Migrations.CreateChatMessages do
  use Ecto.Migration

  def change do
    create table(:chat_messages) do
      add :text, :text
      add :sender_user_id, references(:users, on_delete: :nothing)
      add :chat_id, references(:chats, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_messages, [:sender_user_id])
    create index(:chat_messages, [:chat_id])
  end
end
