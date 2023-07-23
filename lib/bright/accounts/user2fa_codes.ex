defmodule Bright.Accounts.User2faCodes do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "user_2fa_codes" do
    field :code, :string
    field :sent_to, :string
    belongs_to(:user, Bright.Accounts.User)

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(user2fa_codes, attrs) do
    user2fa_codes
    |> cast(attrs, [:code, :sent_to])
    |> validate_required([:code, :sent_to])
  end
end
