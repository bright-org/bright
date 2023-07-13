defmodule Bright.SkillScoreItemFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillScorIteme
  """

  defmacro __using__(_opts) do
    quote do
      def skill_score_item_factory do
        %Bright.SkillScores.SkillScoreItem{
          score: :low
        }
      end
    end
  end
end
