defmodule Bright.SkillExamResultFactory do
  @moduledoc """
  Factory for Bright.SkillExams.SkillExamResult
  """

  defmacro __using__(_opts) do
    quote do
      def skill_exam_result_factory do
        %Bright.SkillExams.SkillExamResult{}
      end
    end
  end
end
