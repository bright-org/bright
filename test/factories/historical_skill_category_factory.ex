defmodule Bright.HistoricalSkillCategoryFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillUnits.HistoricalSkillCategory
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_category_factory do
        %Bright.HistoricalSkillUnits.HistoricalSkillCategory{
          trace_id: Faker.UUID.v4(),
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
