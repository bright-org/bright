defmodule Bright.Jobs.CareerField do
  @moduledoc """
  キャリアフィールドを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_fields" do
    field :background_color, :string
    field :button_color, :string
    field :name, :string
    field :position, :integer

    has_many :jobs, Bright.Jobs.Job
    has_many :career_field_scores, Bright.SkillScores.CareerFieldScore

    timestamps()
  end

  @doc false
  def changeset(career_field, attrs) do
    career_field
    |> cast(attrs, [:name, :background_color, :button_color, :position])
    |> validate_required([:name, :background_color, :button_color, :position])
  end
end
