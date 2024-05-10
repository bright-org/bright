defmodule Bright.Chats.ChatUser do
  @moduledoc """
  Bright チャット参加者を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "chat_users" do
    belongs_to :chat, Bright.Chats.Chat
    belongs_to :user, Bright.Accounts.User
    field :is_read, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(chat_user, attrs) do
    chat_user
    |> cast(attrs, [:chat_id, :user_id, :is_read])
    |> validate_required([:user_id])
  end

  @doc """
  指定されたチャットとユーザーからチャット参加者を取得するクエリ。
  """
  def chat_user_query(chat_id, user_id) do
    from(
      cu in Bright.Chats.ChatUser,
      where: cu.chat_id == ^chat_id and cu.user_id == ^user_id
    )
  end

  @doc """
  チャット参加者全員を取得するクエリ。ただし、送信者は除く。
  """
  def chat_users_except_sender_query(chat_id, sender_user_id) do
    from(
      cu in Bright.Chats.ChatUser,
      where: cu.chat_id == ^chat_id and cu.user_id != ^sender_user_id
    )
  end
end
