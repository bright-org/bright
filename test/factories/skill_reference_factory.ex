defmodule Bright.SkillReferenceFactory do
  @moduledoc """
  Factory for Bright.SkillReferences.SkillReference
  """

  defmacro __using__(_opts) do
    quote do
      def skill_reference_factory do
        %Bright.SkillReferences.SkillReference{
          url: "https://example.com/#{Faker.Internet.slug()}"
        }
      end
    end
  end
end
