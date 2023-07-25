defmodule Bright.SkillExamFactory do
  @moduledoc """
  Factory for Bright.SkillExams.SkillExam
  """

  defmacro __using__(_opts) do
    quote do
      def skill_exam_factory do
        %Bright.SkillExams.SkillExam{
          url: "https://example.com/#{Faker.Internet.slug()}"
        }
      end
    end
  end
end
