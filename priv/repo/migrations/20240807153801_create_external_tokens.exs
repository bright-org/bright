defmodule Bright.Repo.Migrations.CreateExternalTokens do
  use Ecto.Migration

  def change do
    create table(:external_tokens) do
      add :token_type, :string, null: false
      add :token, :string, null: false
      add :api_domain, :string
      add :expired_at, :naive_datetime, null: false

      timestamps()
    end

    create unique_index(:external_tokens, [:token_type])
  end
end
