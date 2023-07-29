defmodule Bright.Jobs.CareerWantJob do
  use Ecto.Schema
  import Ecto.Changeset

  schema "career_want_jobs" do

    field :career_want_id, :id
    field :job_id, :id

    timestamps()
  end

  @doc false
  def changeset(career_want_job, attrs) do
    career_want_job
    |> cast(attrs, [])
    |> validate_required([])
  end
end
