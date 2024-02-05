defmodule Bright.SkillClassScoreLogFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillClassScoreLog
  """

  alias Bright.SkillScores.SkillClassScoreLog

  defmacro __using__(_opts) do
    quote do
      def skill_class_score_log_factory do
        %SkillClassScoreLog{
          percentage: 0.0,
          date: Date.utc_today()
        }
      end
    end
  end
end
