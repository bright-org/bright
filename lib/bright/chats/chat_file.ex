defmodule Bright.Chats.ChatFile do
  @moduledoc """
  Bright チャットメッセージにファイルを添付するためのスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "chat_files" do
    field :file_name, :string
    field :file_type, Ecto.Enum, values: [:image, :file]
    field :file_path, :string
    field :deleted_at, :naive_datetime

    belongs_to :chat_message, Bright.Chats.ChatMessage

    timestamps()
  end

  @doc false
  def changeset(chat_file, attrs) do
    chat_file
    |> cast(attrs, [:file_type, :file_name, :file_path, :deleted_at, :chat_message_id])
    |> validate_required([:file_type, :file_name, :file_path])
  end
end
