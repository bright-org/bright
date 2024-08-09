defmodule Bright.Repo.Migrations.AddCoordinationIdAndEmploymentIdToChats do
  use Ecto.Migration

  def up do
    alter table(:chats) do
      add :coordination_id, :uuid
      add :employment_id, :uuid
    end

    flush()
  end

  def down do
    alter table(:chats) do
      remove :coordination_id
      remove :employment_id
    end
  end
end
