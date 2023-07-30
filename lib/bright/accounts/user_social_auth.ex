defmodule Bright.Accounts.UserSocialAuth do
  @moduledoc """
  Bright ユーザーの SNS 認証・認可を扱うスキーマ
  """
  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_social_auths" do
    field :identifier, :string
    field :provider, :string
    belongs_to(:user, Bright.Accounts.User)

    timestamps()
  end
end
