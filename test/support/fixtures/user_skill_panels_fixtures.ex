defmodule Bright.UserSkillPanelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.UserSkillPanels` context.
  """

  @doc """
  Generate a user_skill_panel.
  """
  def user_skill_panel_fixture(attrs \\ %{}) do
    {:ok, user_skill_panel} =
      attrs
      |> Enum.into(%{
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        skill_panel_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Bright.UserSkillPanels.create_user_skill_panel()

    user_skill_panel
  end
end
