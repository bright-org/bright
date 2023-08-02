defmodule Bright.Accounts.UserSocialAuth do
  @moduledoc """
  Bright ユーザーの SNS 認証・認可を扱うスキーマ
  """
  alias Bright.Accounts.UserSocialAuth
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_social_auths" do
    field :identifier, :string
    field :provider, Ecto.Enum, values: [:google]
    belongs_to(:user, Bright.Accounts.User)

    timestamps()
  end

  def change_user_social_auth(%UserSocialAuth{} = user_social_auth, attrs) do
    user_social_auth
    |> cast(attrs, [:provider, :identifier, :user_id])
  end

  @doc """
  Gets user for the given provider for the given identifier.
  """
  def user_by_provider_and_identifier_query(provider, identifier) do
    from(u in UserSocialAuth,
      join: user in assoc(u, :user),
      where: u.provider == ^provider and u.identifier == ^identifier,
      select: user
    )
  end
end
