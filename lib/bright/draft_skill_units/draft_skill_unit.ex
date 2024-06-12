defmodule Bright.DraftSkillUnits.DraftSkillUnit do
  @moduledoc """
  運営下書きのスキルユニットを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillUnits.DraftSkillCategory
  alias Bright.DraftSkillUnits.DraftSkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skill_units" do
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :name, :string

    has_many :draft_skill_categories, DraftSkillCategory,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :draft_skill_class_units, DraftSkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete,
      on_delete: :delete_all

    has_many :draft_skill_classes, through: [:draft_skill_class_units, :draft_skill_class]

    timestamps()
  end

  @doc false
  def changeset(draft_skill_unit, attrs) do
    draft_skill_unit
    |> cast(attrs, [:name])
    |> cast_assoc(:draft_skill_categories,
      with: &DraftSkillCategory.changeset/2,
      sort_param: :draft_skill_categories_sort,
      drop_param: :draft_skill_categories_drop
    )
    |> cast_assoc(:draft_skill_class_units,
      with: &DraftSkillClassUnit.changeset/2,
      sort_param: :draft_skill_class_units_sort,
      drop_param: :draft_skill_class_units_drop
    )
    |> validate_required([:name])
  end
end
