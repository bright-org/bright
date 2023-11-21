defmodule Bright.Chats.ChatMessage do
  @moduledoc """
  Bright チャットメッセージを扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "chat_messages" do
    field :text, :string

    belongs_to :chat, Bright.Chats.Chat
    belongs_to :sender_user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:text, :sender_user_id, :chat_id])
    |> validate_required([:text, :sender_user_id, :chat_id])
  end
end
