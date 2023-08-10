defmodule Bright.SkillClassScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillClassScore
  """

  alias Bright.SkillScores.SkillClassScore

  defmacro __using__(_opts) do
    quote do
      def skill_class_score_factory do
        %SkillClassScore{
          user: build(:user),
          skill_class: build(:skill_class),
          level: Enum.random(Ecto.Enum.values(SkillClassScore, :level)),
          percentage: Enum.random(0..100)
        }
      end
    end
  end
end
