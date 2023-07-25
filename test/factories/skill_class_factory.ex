defmodule Bright.SkillClassFactory do
  @moduledoc """
  Factory for Bright.SkillPanels.SkillClass
  """

  defmacro __using__(_opts) do
    quote do
      def skill_class_factory do
        %Bright.SkillPanels.SkillClass{
          name: Faker.Lorem.word(),
          class: sequence(:class, & &1, start_at: 1)
        }
      end
    end
  end
end
