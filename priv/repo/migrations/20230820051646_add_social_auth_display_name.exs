defmodule Bright.Repo.Migrations.AddUserSocialAuthDisplayName do
  use Ecto.Migration

  def change do
    alter table(:user_social_auths) do
      add :display_name, :string
    end

    alter table(:social_identifier_tokens) do
      add :display_name, :string
    end
  end
end
