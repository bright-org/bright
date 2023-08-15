defmodule Bright.Repo.Migrations.TeamsUserMembersAddInvitaionToken do
  use Ecto.Migration

  def change do

    alter table(:team_member_users) do
      add :invitation_token, :binary
      add :confirmed_at, :naive_datetime
    end

  end
end
