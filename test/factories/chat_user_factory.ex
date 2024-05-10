defmodule Bright.ChatUserFactory do
  @moduledoc """
  Factory for Bright.Chats.ChatUser
  """

  defmacro __using__(_opts) do
    quote do
      def chat_user_factory do
        %Bright.Chats.ChatUser{
          user: build(:user),
          chat: build(:recruit_chat)
        }
      end
    end
  end
end
