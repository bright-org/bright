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
    |> cast(attrs, [:name, :user_id])
    |> cast_assoc(:member_users, with: &CustomGroupMemberUser.changeset/2)
    |> validate_required([:name, :user_id])
  end
end
