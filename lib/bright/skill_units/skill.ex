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

    belongs_to :skill_category, SkillCategory

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
