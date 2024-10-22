defmodule Bright.CustomGroups.CustomGroupMemberUser do
  @moduledoc """
  カスタムグループとメンバーであるユーザーの関連を扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "custom_group_member_users" do
    field :position, :integer

    belongs_to :custom_group, Bright.CustomGroups.CustomGroup
    belongs_to :user, Bright.Accounts.User, references: :id

    timestamps()
  end

  @doc false
  def changeset(custom_group_member_users, attrs) do
    custom_group_member_users
    |> cast(attrs, [:user_id, :position])
    |> validate_required([:user_id])
  end
end
