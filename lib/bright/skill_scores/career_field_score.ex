defmodule Bright.SkillScores.CareerFieldScore do
  @moduledoc """
  キャリアフィールド単位の集計を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_field_scores" do
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:career_field, Bright.Jobs.CareerField)

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:percentage])
    |> validate_required([:percentage])
  end
end
