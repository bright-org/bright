defmodule Bright.HistoricalSkillScoreFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillScores.SkillScore
  """

  alias Bright.HistoricalSkillScores.HistoricalSkillScore

  defmacro __using__(_opts) do
    quote do
      def historical_skill_score_factory do
        %HistoricalSkillScore{
          user: build(:user),
          historical_skill: build(:historical_skill),
          score: Enum.random(Ecto.Enum.values(HistoricalSkillScore, :score)),
          exam_progress: Enum.random(Ecto.Enum.values(HistoricalSkillScore, :exam_progress)),
          reference_read: Enum.random([false, true]),
          evidence_filled: Enum.random([false, true])
        }
      end
    end
  end
end
