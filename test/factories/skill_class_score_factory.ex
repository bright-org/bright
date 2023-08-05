defmodule Bright.SkillClassScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillClassScore
  """

  defmacro __using__(_opts) do
    quote do
      def skill_class_score_factory do
        %Bright.SkillScores.SkillClassScore{}
      end
    end
  end
end
