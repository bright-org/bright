defmodule Bright.Communities.Community do
  use Ecto.Schema
  import Ecto.Changeset

  schema "communities" do
    field :name, :string
    field :user_id, Ecto.UUID
    field :community_id, Ecto.UUID
    field :participation, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(community, attrs) do
    community
    |> cast(attrs, [:user_id, :community_id, :name, :participation])
    |> validate_required([:user_id, :community_id, :name, :participation])
  end
end
