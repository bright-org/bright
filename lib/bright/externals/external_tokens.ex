defmodule Bright.Externals.ExternalTokens do
  use Ecto.Schema
  import Ecto.Changeset

  schema "external_tokens" do
    field :token, :string
    field :token_type, :string
    field :api_domain, :string
    field :expired_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(external_tokens, attrs) do
    external_tokens
    |> cast(attrs, [:token_type, :token, :api_domain, :expired_at])
    |> validate_required([:token_type, :token, :api_domain, :expired_at])
  end
end
