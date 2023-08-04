defmodule Bright.SkillScores.SkillScore do
  @moduledoc """
  スキル単位のスコアを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_scores" do
    field :score, Ecto.Enum, values: [:low, :middle, :high]

    belongs_to(:skill_class_score, Bright.SkillScores.SkillClassScore)
    belongs_to(:skill, Bright.SkillUnits.Skill)

    timestamps()
  end

  @doc false
  def changeset(skill_score, attrs) do
    skill_score
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
