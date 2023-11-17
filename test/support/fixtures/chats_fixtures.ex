defmodule Bright.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        relation_type: "some relation_type",
        relation_id: "some relation_id"
      })
      |> Bright.Chats.create_chat()

    chat
  end
end
