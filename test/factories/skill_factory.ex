defmodule Bright.SkillFactory do
  @moduledoc """
  Factory for Bright.SkillUnits.Skill
  """

  defmacro __using__(_opts) do
    quote do
      def skill_factory do
        %Bright.SkillUnits.Skill{
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
