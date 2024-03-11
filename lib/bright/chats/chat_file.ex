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
    field :file_type, Ecto.Enum, values: [:images, :files]
    field :file_path, :string
    field :deleted_at, :naive_datetime

    belongs_to :chat_message, Bright.Chats.ChatMessage

    timestamps()
  end

  def build(target, entry) do
    %{
      file_name: entry.client_name,
      file_path: build_file_path(target, entry.client_name, entry.uuid),
      file_type: target
    }
  end

  def build_file_path(:images, file_name, uuid) do
    "chats/image_#{uuid}" <> Path.extname(file_name)
  end

  def build_file_path(:files, file_name, uuid) do
    "chats/file_#{uuid}" <> Path.extname(file_name)
  end

  @doc false
  def changeset(chat_file, attrs) do
    chat_file
    |> cast(attrs, [:file_type, :file_name, :file_path, :deleted_at, :chat_message_id])
    |> validate_required([:file_type, :file_name, :file_path])
  end
end
