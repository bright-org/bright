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
    field :locked_date, :date
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}

    field :name, :string

    has_many :skill_categories, SkillCategory,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_class_units, SkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_classes, through: [:skill_class_units, :skill_class]

    has_many(:skill_unit_scores, Bright.SkillScores.SkillUnitScore)

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:name, :locked_date])
    |> cast_assoc(:skill_categories,
      with: &SkillCategory.changeset/2,
      sort_param: :skill_categories_sort,
      drop_param: :skill_categories_drop
    )
    |> cast_assoc(:skill_class_units,
      with: &SkillClassUnit.changeset/2,
      sort_param: :skill_class_units_sort,
      drop_param: :skill_class_units_drop
    )
    |> validate_required([:name])
  end
end
