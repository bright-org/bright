defmodule Bright.DraftSkillClassFactory do
  @moduledoc """
  Factory for Bright.DraftSkillPanels.DraftSkillClass
  """

  defmacro __using__(_opts) do
    quote do
      def draft_skill_class_factory do
        %Bright.DraftSkillPanels.DraftSkillClass{
          name: Faker.Lorem.word(),
          class: sequence(:class, & &1, start_at: 1)
        }
      end
    end
  end
end
