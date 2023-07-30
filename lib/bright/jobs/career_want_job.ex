defmodule Bright.Jobs.CareerWantJob do
  @moduledoc """
  やりたいこととジョブを関連づけるスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Jobs.CareerWant
  alias Bright.Jobs.Job

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_want_jobs" do
    belongs_to :career_want, CareerWant
    belongs_to :job, Job

    timestamps()
  end

  @doc false
  def changeset(career_want_job, attrs) do
    career_want_job
    |> cast(attrs, [:career_want_id, :job_id])
    |> validate_required([:career_want_id, :job_id])
  end
end
