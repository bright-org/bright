defmodule Bright.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :relation_type, :string
    field :relation_id, :string
    field :owner_user_id, :id

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:relation_type, :relation_id])
    |> validate_required([:relation_type, :relation_id])
  end
end
