defmodule Bright.DraftSkillUnits.DraftSkill do
  @moduledoc """
  運営下書きのスキルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillUnits.DraftSkillCategory

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skills" do
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :name, :string
    field :position, :integer

    belongs_to :draft_skill_category, DraftSkillCategory

    timestamps()
  end

  @doc false
  def changeset(draft_skill, attrs) do
    draft_skill
    |> cast(attrs, [:draft_skill_category_id, :name, :position])
    |> validate_required([:name, :position])
  end
end
