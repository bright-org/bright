defmodule Bright.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chats" do
    field :relation_type, :string
    field :relation_id, :string
    belongs_to :user, Bright.Accounts.User, foreign_key: :owner_user_id

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:relation_type, :relation_id, :owner_user_id])
    |> validate_required([:relation_type, :relation_id, :owner_user_id])
  end
end
