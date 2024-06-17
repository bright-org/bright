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
    field :deleted_at, :naive_datetime

    belongs_to :chat, Bright.Chats.Chat
    belongs_to :sender_user, Bright.Accounts.User

    has_many :files, Bright.Chats.ChatFile, on_delete: :delete_all

    timestamps()
  end

  @doc false
  def changeset(chat_message, attrs \\ %{}) do
    chat_message
    |> cast(attrs, [:text, :sender_user_id, :chat_id])
    |> cast_assoc(:files,
      with: &Bright.Chats.ChatFile.changeset/2
    )
    |> validate_required([:text, :sender_user_id, :chat_id])
  end

  @doc false
  def delete_changeset(chat_message, attrs \\ %{}) do
    chat_message
    |> cast(attrs, [:text, :deleted_at])
    |> validate_required([:text, :deleted_at])
  end
end
