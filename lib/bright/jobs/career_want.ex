defmodule Bright.Jobs.CareerWant do
  @moduledoc """
  やりたいこと・興味関心があることを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Jobs.CareerWantJob

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_wants" do
    field :name, :string
    field :position, :integer
    has_many :career_want_jobs, CareerWantJob

    timestamps()
  end

  @doc false
  def changeset(career_want, attrs) do
    career_want
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
