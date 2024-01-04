defmodule Bright.UserNotificationFactory do
  @moduledoc """
  Factory for Bright.Notifications.UserNotification
  """

  defmacro __using__(_opts) do
    quote do
      def user_notification_factory do
        %Bright.Notifications.UserNotification{
          user: build(:user),
          last_viewed_at: NaiveDateTime.utc_now()
        }
      end
    end
  end
end
