defmodule Bright.ChatsTest do
  use Bright.DataCase

  alias Bright.Chats

  describe "chats" do
    alias Bright.Chats.Chat
    alias Bright.Chats.ChatUser
    alias Bright.Chats.ChatMessage

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

    test "change_message/1 returns a chat message changeset" do
      user = insert(:user)
      chat = insert(:recruit_chat, owner_user_id: user.id)
      message = insert(:chat_message, chat_id: chat.id, sender_user_id: user.id)
      assert %Ecto.Changeset{} = Chats.change_message(message)
    end

    test "create_message/2 with valid data creates a message and broadcast" do
      sender_user = insert(:user)
      interview = insert(:interview)
      chat = insert(:recruit_chat, relation_id: interview.id, owner_user_id: sender_user.id)

      valid_attrs = %{
        text: "some text",
        chat_id: chat.id,
        sender_user_id: sender_user.id
      }

      insert(:chat_user, chat: chat, user: sender_user, is_read: true)
      [chat_user1, chat_user2] = insert_list(2, :chat_user, chat: chat)

      Chats.subscribe(chat.id)

      assert {:ok, %ChatMessage{} = message} = Chats.create_message(valid_attrs, nil)
      assert message.text == "some text"
      assert message.chat_id == chat.id
      assert message.sender_user_id == sender_user.id

      refute Repo.get!(ChatUser, chat_user1.id).is_read
      refute Repo.get!(ChatUser, chat_user2.id).is_read
      assert Repo.get_by!(ChatUser, chat_id: chat.id, user_id: sender_user.id).is_read

      assert_receive {:send_message, ^message}
    end

    test "delete_message_with_broadcast!/1 updates message for deleting and broadcast" do
      message = insert(:chat_message, chat: build(:recruit_chat))
      Chats.subscribe(message.chat_id)

      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      deleted_message = Chats.delete_message_with_broadcast!(message, now)

      assert deleted_message.deleted_at == now
      assert Repo.get!(ChatMessage, message.id).deleted_at == now

      assert_receive {:delete_message, ^deleted_message}
    end

    test "subscribe/1 and broadcast/2" do
      %{id: chat_id} = insert(:recruit_chat)
      message = insert(:chat_message, chat_id: chat_id)

      Chats.subscribe(chat_id)
      Chats.broadcast({:ok, message}, :send_message)

      assert_receive {:send_message, ^message}
    end

    test "read_chat!/2" do
      user = insert(:user)
      chat = insert(:recruit_chat, owner_user_id: user.id)
      chat_user = insert(:chat_user, chat: chat, user: user, is_read: false)

      assert :ok = Chats.read_chat!(chat.id, user.id)
      assert Repo.get!(ChatUser, chat_user.id).is_read
    end
  end
end
