defmodule Bright.Users.BrightUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "bright_users" do
    field :password, :string
    field :handle_name, :string
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(bright_user, attrs) do
    bright_user
    |> cast(attrs, [:handle_name, :email, :password])
    |> validate_required([:handle_name, :email, :password])
  end
end
