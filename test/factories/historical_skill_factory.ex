defmodule Bright.HistoricalSkillFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillUnits.HistoricalSkill
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_factory do
        %Bright.HistoricalSkillUnits.HistoricalSkill{
          trace_id: Faker.UUID.v4(),
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
