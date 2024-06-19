defmodule Bright.Chats.ChatMessage do
  @moduledoc """
  Bright チャットメッセージを扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

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
    |> cast(attrs, [:deleted_at])
    |> validate_required([:deleted_at])
  end

  def not_deleted_message_with_files_query do
    from cm in not_deleted_message_query(),
      preload: [:files]
  end

  defp not_deleted_message_query do
    from cm in Bright.Chats.ChatMessage,
      where: is_nil(cm.deleted_at)
  end
end
