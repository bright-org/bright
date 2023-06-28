defmodule Bright.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Teams` context.
  """

  @doc """
  Generate a team.
  """
  def team_fixture(attrs \\ %{}) do
    {:ok, team} =
      attrs
      |> Enum.into(%{
        team_name: "some team_name",
        enable_hr_functions: true,
        auther_bright_user_id: 42
      })
      |> Bright.Teams.create_team()

    team
  end

  @doc """
  Generate a user_joined_team.
  """
  def user_joined_team_fixture(attrs \\ %{}) do
    {:ok, user_joined_team} =
      attrs
      |> Enum.into(%{
        bright_user_id: 42,
        team_id: 42,
        is_auther: true,
        is_primary_team: true
      })
      |> Bright.Teams.create_user_joined_team()

    user_joined_team
  end

  @doc """
  Generate a team_member_users.
  """
  def team_member_users_fixture(attrs \\ %{}) do
    {:ok, team_member_users} =
      attrs
      |> Enum.into(%{
        is_admin: true,
        is_primary: true,
        team_id: "7488a646-e31f-11e4-aace-600308960662",
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Bright.Teams.create_team_member_users()

    team_member_users
  end
end
