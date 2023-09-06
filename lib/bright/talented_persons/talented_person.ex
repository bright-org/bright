defmodule Bright.TalentedPersons.TalentedPerson do
  use Ecto.Schema
  import Ecto.Changeset

  schema "talented_persons" do
    field :introducer_user_id, Ecto.UUID
    field :fave_user_id, Ecto.UUID
    field :team_id, Ecto.UUID
    field :fave_point, :string

    timestamps()
  end

  @doc false
  def changeset(talented_person, attrs) do
    talented_person
    |> cast(attrs, [:introducer_user_id, :fave_user_id, :team_id, :fave_point])
    |> validate_required([:introducer_user_id, :fave_user_id, :team_id, :fave_point])
  end
end
