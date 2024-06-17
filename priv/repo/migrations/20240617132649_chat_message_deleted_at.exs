defmodule Bright.Repo.Migrations.ChatMessageDeletedAt do
  use Ecto.Migration

  def change do
    alter table(:chat_messages) do
      add :deleted_at, :naive_datetime, default: nil
    end
  end
end
