defmodule Bright.HistoricalSkillUnitScoreFactory do
  @moduledoc """
  Factory for Bright.HistoricalSkillScores.HistoricalSkillUnitScore
  """

  alias Bright.HistoricalSkillScores.HistoricalSkillUnitScore

  defmacro __using__(_opts) do
    quote do
      def historical_skill_unit_score_factory do
        %HistoricalSkillUnitScore{
          user: build(:user),
          historical_skill_unit: build(:historical_skill_unit),
          percentage: 0.0
        }
      end
    end
  end
end
