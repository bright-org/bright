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
    field :num_high_skills, :integer, default: 0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:career_field, Bright.Jobs.CareerField)

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:percentage, :num_high_skills])
    |> validate_required([:percentage, :num_high_skills])
  end
end
