defmodule Bright.SkillUnitScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillUnitScore
  """

  defmacro __using__(_opts) do
    quote do
      def skill_unit_score_factory do
        %Bright.SkillScores.SkillUnitScore{}
      end
    end
  end
end
