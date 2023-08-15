defmodule Bright.SkillClassUnitFactory do
  @moduledoc """
  Factory for Bright.SkillPanels.SkillClassUnit
  """

  defmacro __using__(_opts) do
    quote do
      def skill_class_unit_factory do
        %Bright.SkillUnits.SkillClassUnit{
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
