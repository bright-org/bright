defmodule Bright.Jobs.CareerWant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "career_wants" do
    field :name, :string
    field :position, :integer

    timestamps()
  end

  @doc false
  def changeset(career_want, attrs) do
    career_want
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
