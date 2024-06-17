defmodule Bright.TeamDefaultSkillPanelFactory do
  @moduledoc """
  Factory for Bright.Teams.TeamDefaultSkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def team_default_skill_panel_factory do
        %Bright.Teams.TeamDefaultSkillPanel{
          team: build(:team),
          skill_panel: build(:skill_panel)
        }
      end
    end
  end
end
