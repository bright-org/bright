defmodule Bright.SkillReferences.SkillReference do
  @moduledoc """
  スキルの教材を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_references" do
    field :url, :string

    belongs_to(:skill, Bright.SkillUnits.Skill)

    timestamps()
  end

  @doc false
  def changeset(skill_reference, attrs) do
    skill_reference
    |> cast(attrs, [:url, :skill_id])
    |> validate_required([:url, :skill_id])
  end
end
