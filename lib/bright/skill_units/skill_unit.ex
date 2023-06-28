defmodule Bright.SkillUnits.SkillUnit do
  @moduledoc """
  スキルユニットを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillUnits.SkillCategory
  alias Bright.SkillUnits.SkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_units" do
    field :name, :string

    has_many :skill_categories, SkillCategory,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_class_units, SkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_classes, through: [:skill_class_units, :skill_class]

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:name])
    |> cast_assoc(:skill_categories)
    |> cast_assoc(:skill_class_units)
    |> validate_required([:name])
  end
end
