defmodule Bright.Jobs.Job do
  use Ecto.Schema
  import Ecto.Changeset

  schema "jobs" do
    field :name, :string
    field :position, :integer
    field :career_fied_id, :id

    timestamps()
  end

  @doc false
  def changeset(job, attrs) do
    job
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
