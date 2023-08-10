defmodule Bright.SkillScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillScore
  """

  alias Bright.SkillScores.SkillScore

  defmacro __using__(_opts) do
    quote do
      def skill_score_factory do
        %SkillScore{
          user: build(:user),
          skill: build(:skill),
          score: Enum.random(Ecto.Enum.values(SkillScore, :score))
        }
      end
    end
  end
end
