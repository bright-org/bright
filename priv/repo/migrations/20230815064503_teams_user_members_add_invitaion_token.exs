defmodule Bright.Repo.Migrations.TeamsUserMembersAddInvitaionToken do
  use Ecto.Migration

  def change do
    alter table(:team_member_users) do
      add :invitation_token, :binary
      add :invitation_confirmed_at, :naive_datetime
      add :invitation_sent_to, :string
    end
  end
end
