defmodule Bright.Accounts.UserSubEmail do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_sub_emails" do
    field :email, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_sub_email, attrs) do
    user_sub_email
    |> cast(attrs, [:email])
    |> validate_required([:email])
  end
end
