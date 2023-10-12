defmodule Bright.DraftSkillCategoryFactory do
  @moduledoc """
  Factory for Bright.DraftSkillUnits.DraftSkillCategory
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_category_factory do
        %Bright.DraftSkillUnits.DraftSkillCategory{
          name: Faker.Lorem.word(),
          position: sequence(:position, & &1)
        }
      end
    end
  end
end
