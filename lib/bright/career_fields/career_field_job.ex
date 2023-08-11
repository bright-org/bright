defmodule Bright.CareerFields.CareerFieldJob do
  @moduledoc """
  キャリアフィールドとジョブを関連づけるスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_field_jobs" do
    belongs_to :career_field, Bright.CareerFields.CareerField
    belongs_to :job, Bright.Jobs.Job

    timestamps()
  end

  @doc false
  def changeset(career_field_job, attrs) do
    career_field_job
    |> cast(attrs, [:career_field_id, :job_id])
  end
end
