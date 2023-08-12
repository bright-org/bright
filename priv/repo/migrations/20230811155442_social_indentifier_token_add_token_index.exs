defmodule Bright.Repo.Migrations.SocialIndentifierTokenAddTokenIndex do
  use Ecto.Migration

  def change do
    create index(:social_identifier_tokens, [:token, :inserted_at])
  end
end
