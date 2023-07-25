defmodule Bright.Accounts.User2faCodes do
  @moduledoc """
  User two factor auth code
  """
  alias Bright.Accounts.User2faCodes
  use Ecto.Schema
  import Ecto.Query, warn: false

  @two_factor_auth_code_validity %{"ago" => 10, "intervals" => "minute"}

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "user_2fa_codes" do
    field :code, :string
    field :sent_to, :string
    belongs_to(:user, Bright.Accounts.User)

    timestamps(updated_at: false)
  end

  @doc """
  Build by user.
  """
  def build_by_user(user) do
    %User2faCodes{
      code: generate_code(),
      sent_to: user.email,
      user: user
    }
  end

  defp generate_code do
    Enum.random(0..999_999)
    |> Integer.to_string()
    |> String.pad_leading(6, "0")
  end

  @doc """
  Query for searching by user.
  """
  def user_query(user) do
    from(user_2fa_code in User2faCodes, where: user_2fa_code.user_id == ^user.id)
  end

  @doc """
  Check if the token is valid and not expired.
  """
  def verify_user_2fa_code_query(user, code) do
    from(user_2fa_code in User2faCodes,
      where:
        user_2fa_code.user_id == ^user.id and
          user_2fa_code.code == ^code and
          user_2fa_code.inserted_at >
            ago(
              ^@two_factor_auth_code_validity["ago"],
              ^@two_factor_auth_code_validity["intervals"]
            )
    )
  end
end
