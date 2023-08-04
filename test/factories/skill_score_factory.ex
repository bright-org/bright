defmodule Bright.SkillScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillScorIteme
  """

  defmacro __using__(_opts) do
    quote do
      def skill_score_factory do
        %Bright.SkillScores.SkillScore{
          score: :low
        }
      end
    end
  end
end
