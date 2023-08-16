defmodule Bright.SkillScores.SkillUnitScore do
  @moduledoc """
  スキルユニット単位の集計を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_unit_scores" do
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill_unit, Bright.SkillUnits.SkillUnit)

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:percentage])
    |> validate_required([:percentage])
  end
end
