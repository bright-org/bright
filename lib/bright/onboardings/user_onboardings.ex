defmodule Bright.Onboardings.UserOnboardings do
  @moduledoc """
  ユーザーのオンボーディング結果を扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Accounts.User

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_onboardings" do
    field :completed_at, :naive_datetime
    # field :user_id, :id

    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_onboardings, attrs) do
    user_onboardings
    |> cast(attrs, [:completed_at])
    |> validate_required([:completed_at])
  end
end
