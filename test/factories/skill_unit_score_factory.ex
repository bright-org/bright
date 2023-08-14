defmodule Bright.SkillUnitScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillUnitScore
  """

  defmacro __using__(_opts) do
    quote do
      def skill_unit_score_factory do
        %Bright.SkillScores.SkillUnitScore{
          user: build(:user),
          skill_unit: build(:skill_unit),
          percentage: Enum.random(0..100)
        }
      end
    end
  end
end
