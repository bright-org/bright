defmodule Bright.Repo.Migrations.CreateChatFiles do
  use Ecto.Migration

  def change do
    create table(:chat_files) do
      add :file_type, :string, null: false
      add :file_name, :string, null: false
      add :file_path, :string, null: false
      add :deleted_at, :naive_datetime
      add :chat_message_id, references(:chat_messages, on_delete: :nothing)

      timestamps()
    end

    create index(:chat_files, [:chat_message_id])
  end
end
