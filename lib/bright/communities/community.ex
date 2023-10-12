defmodule Bright.Communities.Community do
  @moduledoc """
  コミュニティを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "communities" do
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(community, attrs) do
    community
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
