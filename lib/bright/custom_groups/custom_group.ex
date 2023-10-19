defmodule Bright.CustomGroups.CustomGroup do
  @moduledoc """
  カスタムグループを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.CustomGroups.CustomGroupMemberUser

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "custom_groups" do
    field :name, :string

    belongs_to :user, Bright.Accounts.User, references: :id

    has_many :member_users,
      Bright.CustomGroups.CustomGroupMemberUser,
      preload_order: [asc: :position],
      on_replace: :delete,
      on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(custom_group, attrs) do
    custom_group
    |> cast(attrs, [:user_id, :name])
    |> cast_assoc(:member_users, with: &CustomGroupMemberUser.changeset/2)
    |> validate_required([:user_id, :name])
    |> unique_constraint([:user_id, :name], error_key: :name)
  end
end
