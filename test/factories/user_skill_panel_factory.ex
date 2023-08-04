defmodule Bright.UserSkillPanelFactory do
  @moduledoc """
  Factory for Bright.UserSkillPanels.UserSkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def user_skill_panel_factory do
        %Bright.UserSkillPanels.UserSkillPanel{
          user: build(:user),
          skill_panel: build(:skill_panel)
        }
      end
    end
  end
end
