defmodule Bright.ChatFactory do
  @moduledoc """
  Factory for Bright.Chats.Chat
  """

  defmacro __using__(_opts) do
    quote do
      def recruit_chat_factory do
        %Bright.Chats.Chat{
          relation_type: "recruit"
        }
      end
    end
  end
end
