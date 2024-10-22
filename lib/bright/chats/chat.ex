defmodule Bright.Chats.Chat do
  @moduledoc """
  Bright チャットを扱うスキーマ
  """

  alias Bright.Chats.ChatUser
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "chats" do
    field :relation_type, :string
    field :relation_id, Ecto.ULID
    field :coordination_id, Ecto.ULID
    field :employment_id, Ecto.ULID
    field :interview, :any, virtual: true
    field :coordination, :any, virtual: true
    field :employment, :any, virtual: true

    belongs_to :owner_user, Bright.Accounts.User

    has_many :chat_users, Bright.Chats.ChatUser, on_delete: :delete_all
    has_many :users, through: [:chat_users, :user]

    has_many :messages,
             Bright.Chats.ChatMessage,
             on_delete: :delete_all,
             preload_order: [asc: :inserted_at]

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [
      :relation_type,
      :relation_id,
      :coordination_id,
      :employment_id,
      :owner_user_id,
      :updated_at
    ])
    |> cast_assoc(:chat_users, with: &ChatUser.changeset/2)
    |> validate_required([:relation_type, :relation_id, :owner_user_id])
  end
end
