defmodule Bright.Externals.ExternalToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "external_tokens" do
    field :token, :string
    field :token_type, Ecto.Enum, values: [:ZOHO_CRM]
    field :api_domain, :string
    field :expired_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(external_tokens, attrs) do
    external_tokens
    |> cast(attrs, [:token_type, :token, :api_domain, :expired_at])
    |> validate_required([:token_type, :token, :expired_at])
    |> validate_inclusion(:token_type, token_types())
  end

  @doc """
  Returns a list of token types.
  """
  def token_types do
    Ecto.Enum.values(__MODULE__, :token_type)
  end
end
