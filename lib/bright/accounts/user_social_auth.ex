defmodule Bright.Accounts.UserSocialAuth do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_social_auths" do
    field :identifier, :string
    field :provider, :string
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_social_auth, attrs) do
    user_social_auth
    |> cast(attrs, [:provider, :identifier])
    |> validate_required([:provider, :identifier])
  end
end
