defmodule Bright.CareerFieldScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.CareerFieldScore
  """

  defmacro __using__(_opts) do
    quote do
      def career_field_score_factory do
        %Bright.SkillScores.CareerFieldScore{
          user: build(:user),
          career_field: build(:career_field),
          percentage: Enum.random(0..100),
          high_skills_count: Enum.random(0..10)
        }
      end
    end
  end
end
