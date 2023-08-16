defmodule Bright.HistoricalSkillClassUnitFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillUnits.SkillClassUnit
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_class_unit_factory do
        %Bright.HistoricalSkillUnits.HistoricalSkillClassUnit{
          trace_id: Ecto.ULID.generate(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
