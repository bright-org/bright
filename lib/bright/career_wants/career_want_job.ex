defmodule Bright.CareerWants.CareerWantJob do
  @moduledoc """
  やりたいこととジョブを関連づけるスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_want_jobs" do
    belongs_to :career_want, Bright.CareerWants.CareerWant
    belongs_to :job, Bright.Jobs.Job

    timestamps()
  end

  @doc false
  def changeset(career_want_job, attrs) do
    career_want_job
    |> cast(attrs, [:career_want_id, :job_id])
  end
end
