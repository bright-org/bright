defmodule Bright.Accounts.SocialIdentifierToken do
  @moduledoc """
  OAuth で渡ってきた identifier (uid など) を紐づけるトークン
  """

  use Ecto.Schema
  import Ecto.Query
  alias Bright.Accounts.SocialIdentifierToken

  @hash_algorithm :sha256
  @rand_size 32

  @session_validity %{"ago" => 1, "intervals" => "hour"}

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "social_identifier_tokens" do
    field :identifier, :string
    field :token, :binary
    field :provider, Ecto.Enum, values: [:google]
    field :name, :string
    field :email, :string
    field :display_name, :string

    timestamps(updated_at: false)
  end

  @doc """
  Build hashed token by provider and identifier.
  """
  def build_token(%{
        name: name,
        email: email,
        display_name: display_name,
        provider: provider,
        identifier: identifier
      }) do
    token = :crypto.strong_rand_bytes(@rand_size)
    hashed_token = :crypto.hash(@hash_algorithm, token)

    {Base.url_encode64(token, padding: false),
     %SocialIdentifierToken{
       token: hashed_token,
       provider: provider,
       identifier: identifier,
       display_name: display_name,
       name: name,
       email: email
     }}
  end

  @doc """
  Verify token.
  """
  def verify_token_query(token) do
    case Base.url_decode64(token, padding: false) do
      {:ok, decoded_token} ->
        hashed_token = :crypto.hash(@hash_algorithm, decoded_token)

        query =
          from(social_identifier_token in SocialIdentifierToken,
            where:
              social_identifier_token.token == ^hashed_token and
                social_identifier_token.inserted_at >
                  ago(
                    ^@session_validity["ago"],
                    ^@session_validity["intervals"]
                  )
          )

        {:ok, query}

      :error ->
        :error
    end
  end

  @doc """
  Gets token for the given provider for the given identifier.
  """
  def provider_and_identifier_query(provider, identifier) do
    from(s in SocialIdentifierToken,
      where: s.provider == ^provider and s.identifier == ^identifier
    )
  end
end
