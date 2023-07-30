defmodule Bright.SkillCategoryFactory do
  @moduledoc """
  Factory for Bright.SkillUnits.SkillCategory
  """

  defmacro __using__(_opts) do
    quote do
      def skill_category_factory do
        %Bright.SkillUnits.SkillCategory{
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
