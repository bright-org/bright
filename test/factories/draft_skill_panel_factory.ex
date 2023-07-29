defmodule Bright.DraftSkillPanelFactory do
  @moduledoc """
  Factory for Bright.DraftSkillPanels.SkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_panel_factory do
        %Bright.DraftSkillPanels.SkillPanel{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
