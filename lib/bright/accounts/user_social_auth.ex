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
    field :provider, Ecto.Enum, values: [:google, :github, :facebook, :twitter]
    field :display_name, :string
    belongs_to(:user, Bright.Accounts.User)

    timestamps()
  end

  def change_user_social_auth(%UserSocialAuth{} = user_social_auth, attrs) do
    user_social_auth
    |> cast(attrs, [:provider, :identifier, :user_id, :display_name])
    |> validate_required([:provider, :identifier, :user_id])
    |> unique_constraint([:user_id, :provider], error_key: :unique_user_provider)
    |> unique_constraint([:provider, :identifier], error_key: :unique_provider_identifier)
  end

  @doc """
  Gets a user for the given provider for the given identifier.
  """
  def user_by_provider_and_identifier_query(provider, identifier) do
    from(u in UserSocialAuth,
      join: user in assoc(u, :user),
      where: u.provider == ^provider and u.identifier == ^identifier,
      select: user
    )
  end

  @doc """
  Gets a user_social_auth by the given user_id and provider.
  """
  def user_id_and_provider_query(user_id, provider) do
    from(u in UserSocialAuth, where: u.user_id == ^user_id and u.provider == ^provider)
  end

  # Gets user_social_auths by the given user_id and provider
  def user_other_provider_query(user_id, provider) do
    from(u in UserSocialAuth, where: u.user_id == ^user_id and u.provider != ^provider)
  end

  @doc """
  Returns providers.
  """
  def providers do
    Ecto.Enum.values(__MODULE__, :provider)
  end

  @doc """
  Returns provider name by provider.
  """
  def provider_name(provider) do
    %{
      google: "Google",
      github: "GitHub",
      facebook: "Facebook",
      twitter: "Twitter"
    }
    |> Map.fetch!(provider)
  end
end
