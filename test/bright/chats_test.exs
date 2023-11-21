defmodule Bright.ChatsTest do
  use Bright.DataCase

  alias Bright.Chats
  import Bright.Factory

  describe "chats" do
    alias Bright.Chats.Chat

    @invalid_attrs %{relation_type: nil, relation_id: nil}

    test "list_chats/0 returns all chats" do
      chat = insert(:recruit_chat)

      assert Chats.list_chats() == [chat]
    end

    test "get_chat!/1 returns the chat with given id" do
      chat = insert(:recruit_chat)
      assert Chats.get_chat!(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      user = insert(:user)
      interview = insert(:interview)

      valid_attrs = %{
        relation_type: "recruit",
        relation_id: interview.id,
        owner_user_id: user.id
      }

      assert {:ok, %Chat{} = chat} = Chats.create_chat(valid_attrs)
      assert chat.relation_type == "recruit"
      assert chat.relation_id == interview.id
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = insert(:recruit_chat)
      user = insert(:user)
      interview = insert(:interview)

      update_attrs = %{
        relation_type: "1on1",
        relation_id: interview.id,
        owner_user_id: user.id
      }

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, update_attrs)
      assert chat.relation_type == "1on1"
    end

    test "update_chat/2 with invalid data returns error changeset" do
      chat = insert(:recruit_chat)
      assert {:error, %Ecto.Changeset{}} = Chats.update_chat(chat, @invalid_attrs)
      assert chat == Chats.get_chat!(chat.id)
    end

    test "delete_chat/1 deletes the chat" do
      chat = insert(:recruit_chat)
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = insert(:recruit_chat)
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
