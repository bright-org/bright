defmodule Bright.SkillScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillScore
  """

  defmacro __using__(_opts) do
    quote do
      def skill_score_factory do
        %Bright.SkillScores.SkillScore{}
      end
    end
  end
end
