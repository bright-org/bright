defmodule Bright.Jobs.Job do
  @moduledoc """
  ジョブを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Jobs.CareerField

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "jobs" do
    field :name, :string
    field :position, :integer

    belongs_to :career_fied, CareerField

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
