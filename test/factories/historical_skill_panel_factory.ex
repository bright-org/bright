defmodule Bright.HistoricalSkillPanelFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillPanels.SkillPanel
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_panel_factory do
        %Bright.HistoricalSkillPanels.SkillPanel{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
