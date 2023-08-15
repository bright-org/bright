defmodule Bright.CareerWants.CareerWant do
  @moduledoc """
  やりたいこと・興味関心があることを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.CareerWants.CareerWantJob

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_wants" do
    field :name, :string
    field :position, :integer

    has_many :career_want_jobs, CareerWantJob, on_replace: :delete
    has_many :jobs, through: [:career_want_jobs, :job]

    timestamps()
  end

  @doc false
  def changeset(career_want, attrs) do
    career_want
    |> cast(attrs, [:name, :position])
    |> cast_assoc(:career_want_jobs,
      with: &CareerWantJob.changeset/2,
      sort_param: :career_want_jobs_sort,
      drop_param: :career_want_jobs_drop
    )
    |> validate_required([:name, :position])
  end
end
