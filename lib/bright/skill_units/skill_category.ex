defmodule Bright.SkillUnits.SkillCategory do
  @moduledoc """
  スキルユニットのカテゴリを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillUnits.SkillUnit
  alias Bright.SkillUnits.Skill

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_categories" do
    field :name, :string
    field :position, :integer

    belongs_to :skill_unit, SkillUnit
    has_many :skills, Skill, preload_order: [asc: :position], on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_category, attrs) do
    skill_category
    |> cast(attrs, [:name, :position])
    |> cast_assoc(:skills)
    |> validate_required([:name, :position])
  end
end
