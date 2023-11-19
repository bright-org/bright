defmodule Bright.ChatMessageFactory do
  @moduledoc """
  Factory for Bright.Chats.ChatMessage
  """

  defmacro __using__(_opts) do
    quote do
      def chat_message_factory do
        %Bright.Chats.ChatMessage{
          text: "some text"
        }
      end
    end
  end
end
