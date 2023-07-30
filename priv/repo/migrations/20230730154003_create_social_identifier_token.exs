defmodule Bright.Repo.Migrations.CreateSocialIdentifierToken do
  use Ecto.Migration

  def change do
    create table(:social_identifier_tokens) do
      add :provider, :string
      add :identifier, :string
      add :token, :binary

      timestamps(updated_at: false)
    end

    create unique_index(:social_identifier_tokens, [:provider, :identifier])
  end
end
