defmodule Bright.Chats.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :text, :string

    belongs_to :chat, Bright.Chats.Chat
    belongs_to :user, Bright.Accounts.User, foreign_key: :sender_user_id

    timestamps()
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:text, :sender_user_id, :chat_id])
    |> validate_required([:text, :sender_user_id, :chat_id])
  end
end
