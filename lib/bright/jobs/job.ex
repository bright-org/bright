defmodule Bright.Jobs.Job do
  @moduledoc """
  ジョブを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Jobs.{CareerWantJob, JobSkillPanel}
  alias Bright.CareerFields.CareerField

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "jobs" do
    field :name, :string
    field :description, :string
    field :position, :integer
    field :rank, Ecto.Enum, values: [:basic, :advanced, :expert]
    belongs_to :career_field, CareerField

    has_one :career_want_job, CareerWantJob
    has_many :job_skill_panels, JobSkillPanel

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :position, :description, :rank, :career_field_id])
    |> validate_required([:name, :position, :description, :rank, :career_field_id])
  end
end
