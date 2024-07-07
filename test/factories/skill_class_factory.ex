defmodule Bright.SkillClassFactory do
  @moduledoc """
  Factory for Bright.SkillPanels.SkillClass
  """

  defmacro __using__(_opts) do
    quote do
      def skill_class_factory do
        %Bright.SkillPanels.SkillClass{
          locked_date: Faker.Date.backward(10),
          trace_id: Ecto.ULID.generate(),
          name: Faker.Lorem.word(),
          class: sequence(:class, & &1, start_at: 1)
        }
      end

      def skill_class_with_skill_panel_factory do
        build(:skill_class, skill_panel: build(:skill_panel))
      end
    end
  end
end
