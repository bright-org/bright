defmodule Bright.CareerFields.CareerField do
  @moduledoc """
  キャリアフィールドを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Jobs.Job
  alias Bright.SkillScores.CareerFieldScore
  alias Bright.CareerFields.CareerFieldSkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_fields" do
    field :name_en, :string
    field :name_ja, :string
    field :position, :integer

    has_many :jobs, Job
    has_many :career_field_scores, CareerFieldScore

    has_many :career_field_skill_panels, CareerFieldSkillPanel, on_replace: :delete
    has_many :skill_panels, through: [:career_field_skill_panels, :skill_panel]

    timestamps()
  end

  @doc false
  def changeset(career_field, attrs) do
    career_field
    |> cast(attrs, [:name_en, :name_ja, :position])
    |> validate_required([:name_en, :name_ja, :position])
  end
end
