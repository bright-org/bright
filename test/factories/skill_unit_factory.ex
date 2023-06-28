defmodule Bright.SkillUnitFactory do
  @moduledoc """
  Factory for Bright.SkillUnits.SkillUnit
  """

  defmacro __using__(_opts) do
    quote do
      def skill_unit_factory do
        %Bright.SkillUnits.SkillUnit{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
