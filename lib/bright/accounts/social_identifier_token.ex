defmodule Bright.Accounts.SocialIdentifierToken do
  @moduledoc """
  OAuth で渡ってきた identifier (uid など) を紐づけるトークン
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "social_identifier_tokens" do
    field :identifier, :string
    field :token, :binary
    field :provider, :string

    timestamps(updated_at: false)
  end
end
