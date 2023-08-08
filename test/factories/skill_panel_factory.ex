defmodule Bright.SkillPanelFactory do
  @moduledoc """
  Factory for Bright.SkillPanels.SkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def skill_panel_factory do
        %Bright.SkillPanels.SkillPanel{
          name: Faker.Lorem.word(),
          career_field: build(:career_field)
        }
      end
    end
  end
end
