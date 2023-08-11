defmodule Bright.DraftSkillClassUnitFactory do
  @moduledoc """
  Factory for Bright.DraftSkillUnits.DraftSkillClassUnit
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_class_unit_factory do
        %Bright.DraftSkillUnits.DraftSkillClassUnit{
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
