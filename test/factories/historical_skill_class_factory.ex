defmodule Bright.HistoricalSkillClassFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillPanels.HistoricalSkillClass
  """

  defmacro __using__(_opts) do
    quote do
      def historical_skill_class_factory do
        %Bright.HistoricalSkillPanels.HistoricalSkillClass{
          trace_id: Ecto.ULID.generate(),
          name: Faker.Lorem.word(),
          class: sequence(:class, & &1, start_at: 1)
        }
      end
    end
  end
end
