defmodule Bright.Jobs.JobSkillPanel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "job_skill_panels" do

    field :job_id, :id
    field :skill_panel_id, :id

    timestamps()
  end

  @doc false
  def changeset(job_skill_panel, attrs) do
    job_skill_panel
    |> cast(attrs, [])
    |> validate_required([])
  end
end
