defmodule Bright.SkillPanelsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.SkillPanels` context.
  """

  @doc """
  Generate a skill_panel.
  """
  def skill_panel_fixture(attrs \\ %{}) do
    {:ok, skill_panel} =
      attrs
      |> Enum.into(%{
        name: "some name",
        locked_date: ~D[2023-06-15]
      })
      |> Bright.SkillPanels.create_skill_panel()

    skill_panel
  end
end
