defmodule Bright.CustomGroups.CustomGroup do
  @moduledoc """
  カスタムグループを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "custom_groups" do
    field :name, :string

    belongs_to :user, Bright.Accounts.User, references: :id
    has_many :member_users, Bright.CustomGroups.CustomGroupMemberUser

    timestamps()
  end

  @doc false
  def changeset(custom_group, attrs) do
    custom_group
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
  end
end
