defmodule Bright.CareerFields.CareerField do
  @moduledoc """
  キャリアフィールドを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.CareerFields.CareerFieldJob

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_fields" do
    field :name_en, :string
    field :name_ja, :string
    field :position, :integer

    has_many :career_field_jobs, CareerFieldJob
    has_many :jobs, through: [:career_field_jobs, :job]
    has_many :career_field_scores, Bright.SkillScores.CareerFieldScore

    has_many :historical_career_field_scores,
             Bright.HistoricalSkillScores.HistoricalCareerFieldScore

    timestamps()
  end

  @doc false
  def changeset(career_field, attrs) do
    career_field
    |> cast(attrs, [:name_en, :name_ja, :position])
    |> validate_required([:name_en, :name_ja, :position])
  end
end
