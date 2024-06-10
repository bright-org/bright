defmodule Bright.DraftSkillUnits.DraftSkillCategory do
  @moduledoc """
  運営下書きのスキルカテゴリを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillUnits.DraftSkillUnit
  alias Bright.DraftSkillUnits.DraftSkill

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skill_categories" do
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :name, :string
    field :position, :integer

    belongs_to :draft_skill_unit, DraftSkillUnit

    has_many :draft_skills, DraftSkill,
      preload_order: [asc: :position],
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(draft_skill_category, attrs) do
    draft_skill_category
    |> cast(attrs, [:name, :position, :draft_skill_unit_id])
    |> cast_assoc(:draft_skills,
      with: &DraftSkill.changeset/2,
      sort_param: :draft_skills_sort,
      drop_param: :draft_skills_drop
    )
    |> validate_required([:name, :position])
  end
end
