defmodule Bright.Jobs.Job do
  @moduledoc """
  ジョブを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Jobs.JobSkillPanel
  alias Bright.CareerFields.CareerFieldJob

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "jobs" do
    field :name, :string
    field :description, :string
    field :position, :integer
    field :rank, Ecto.Enum, values: [:basic, :advanced, :expert]
    field :career_field_id, :string

    has_many :career_field_jobs, CareerFieldJob, on_replace: :delete
    has_many :career_fields, through: [:career_field_jobs, :career_field]
    has_many :job_skill_panels, JobSkillPanel, on_replace: :delete
    has_many :skill_panels, through: [:job_skill_panels, :skill_panel]

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :position, :description, :rank])
    |> cast_assoc(:career_field_jobs,
      with: &CareerFieldJob.changeset/2,
      sort_param: :career_field_jobs_sort,
      drop_param: :career_field_jobs_drop
    )
    |> cast_assoc(:job_skill_panels,
      with: &JobSkillPanel.changeset/2,
      sort_param: :job_skill_panels_sort,
      drop_param: :job_skill_Panels_drop
    )
    |> validate_required([:name, :position, :description, :rank])
  end
end
