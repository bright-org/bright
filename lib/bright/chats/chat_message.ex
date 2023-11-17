defmodule Bright.Chats.ChatMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_messages" do
    field :text, :string
    field :sender_user_id, :id
    field :chat_id, :id

    timestamps()
  end

  @doc false
  def changeset(chat_message, attrs) do
    chat_message
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
