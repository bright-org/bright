defmodule Bright.HistoricalSkillUnitFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillUnits.HistoricalSkillUnit
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_unit_factory do
        %Bright.HistoricalSkillUnits.HistoricalSkillUnit{
          locked_date: Faker.Date.backward(10),
          trace_id: Ecto.ULID.generate(),
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
