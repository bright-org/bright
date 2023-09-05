defmodule Bright.SkillScoreFactory do
  @moduledoc """
  Factory for Bright.SkillScores.SkillScore
  """

  alias Bright.SkillScores.SkillScore

  defmacro __using__(_opts) do
    quote do
      def init_skill_score_factory do
        %SkillScore{
          user: build(:user),
          skill: build(:skill)
        }
      end

      def skill_score_factory do
        %SkillScore{
          user: build(:user),
          skill: build(:skill),
          score: Enum.random(Ecto.Enum.values(SkillScore, :score)),
          exam_progress: Enum.random(Ecto.Enum.values(SkillScore, :exam_progress)),
          reference_read: Enum.random([false, true]),
          evidence_filled: Enum.random([false, true])
        }
      end

      def make_fullmark(%SkillScore{} = skill_score) do
        skill_score
        |> Map.merge(%{
          score: :high,
          exam_progress: :done,
          reference_read: true,
          evidence_filled: true
        })
      end
    end
  end
end
