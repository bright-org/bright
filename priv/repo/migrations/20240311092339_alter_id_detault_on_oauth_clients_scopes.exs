defmodule Bright.Repo.Migrations.AlterIdDetaultOnOauthClientsScopes do
  use Ecto.Migration

  def change do
    alter table(:oauth_clients_scopes) do
      modify :id, :uuid, default: fragment("gen_random_uuid()"), from: {:uuid, default: nil}
    end
  end
end
