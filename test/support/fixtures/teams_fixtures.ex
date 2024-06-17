defmodule Bright.TeamsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Teams` context.
  """

  @doc """
  Generate a team_default_skill_panel.
  """
  def team_default_skill_panel_fixture(attrs \\ %{}) do
    {:ok, team_default_skill_panel} =
      attrs
      |> Enum.into(%{
        skill_panel_id: "7488a646-e31f-11e4-aace-600308960662",
        team_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Bright.Teams.create_team_default_skill_panel()

    team_default_skill_panel
  end
end
