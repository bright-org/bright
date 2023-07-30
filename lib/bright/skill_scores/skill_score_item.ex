defmodule Bright.SkillScores.SkillScoreItem do
  @moduledoc """
  スキル単位のスコアを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_score_items" do
    field :score, Ecto.Enum, values: [:low, :middle, :high]

    belongs_to(:skill_score, Bright.SkillScores.SkillScore)
    belongs_to(:skill, Bright.SkillUnits.Skill)

    timestamps()
  end

  @doc false
  def changeset(skill_score_item, attrs) do
    skill_score_item
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
