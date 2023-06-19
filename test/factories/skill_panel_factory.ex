defmodule Bright.SkillPanelFactory do
  @moduledoc """
  Factory for Bright.SkillPanels.SkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def skill_panel_factory do
        %Bright.SkillPanels.SkillPanel{
          locked_date: nil,
          name: Faker.Lorem.word()
        }
      end

      def locked_skill_panel_factory do
        build(:skill_panel, locked_date: Faker.Date.backward(10))
      end
    end
  end
end
