defmodule Bright.Chats.ChatUser do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "chat_users" do
    belongs_to :chat, Bright.Chats.Chat
    belongs_to :user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [:chat_id, :user_id])
    |> validate_required([:user_id])
  end
end
