defmodule Bright.Repo.Migrations.RenameTeamMemberUsersIsPrimaryToIsStar do
  use Ecto.Migration

  def change do
    rename table("team_member_users"), :is_primary, to: :is_star
  end
end
