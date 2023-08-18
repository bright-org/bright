defmodule Bright.HistoricalSkillClassScoreFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillScores.HistoricalSkillClassScore
  """

  alias Bright.HistoricalSkillScores.HistoricalSkillClassScore

  defmacro __using__(_opts) do
    quote do
      def historical_skill_class_score_factory do
        %HistoricalSkillClassScore{
          user: build(:user),
          historical_skill_class: build(:historical_skill_class),
          level: Enum.random(Ecto.Enum.values(HistoricalSkillClassScore, :level)),
          percentage: Enum.random(0..100)
        }
      end
    end
  end
end
