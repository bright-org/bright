defmodule Bright.DraftSkillUnitFactory do
  @moduledoc """
  Factory for Bright.DraftSkillUnits.DraftSkillUnit
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_unit_factory do
        %Bright.DraftSkillUnits.DraftSkillUnit{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
