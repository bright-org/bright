defmodule Bright.Chats.ChatUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_users" do

    field :chat_id, :id
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [])
    |> validate_required([])
  end
end
