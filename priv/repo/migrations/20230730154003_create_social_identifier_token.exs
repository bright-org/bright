defmodule Bright.Repo.Migrations.CreateSocialIdentifierToken do
  use Ecto.Migration

  def change do
    create table(:social_identifier_tokens) do
      add :provider, :string, null: false
      add :identifier, :string, null: false
      add :token, :binary, null: false
      add :name, :string
      add :email, :citext

      timestamps(updated_at: false)
    end

    create unique_index(:social_identifier_tokens, [:provider, :identifier])
  end
end
