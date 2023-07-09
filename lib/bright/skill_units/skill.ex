defmodule Bright.SkillUnits.Skill do
  @moduledoc """
  スキルユニットのスキルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillUnits.SkillCategory

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skills" do
    field :name, :string
    field :position, :integer

    belongs_to :skill_category, SkillCategory

    has_many :skill_score_items, Bright.SkillScores.SkillScoreItem

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
