defmodule Bright.DraftSkillFactory do
  @moduledoc """
  Factory for Bright.DraftSkillUnits.DraftSkill
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_factory do
        %Bright.DraftSkillUnits.DraftSkill{
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
