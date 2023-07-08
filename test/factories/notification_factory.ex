defmodule Bright.NotificationFactory do
  @moduledoc """
  Factory for Bright.Notifications.Notification
  """

  defmacro __using__(_opts) do
    quote do
      def notification_factory do
        %Bright.Notifications.Notification{
          from_user: build(:user),
          to_user: build(:user),
          icon_type: Faker.Lorem.word(),
          message: Faker.Lorem.word(),
          type: Faker.Lorem.word(),
          url: "/" <> Faker.Lorem.word()
        }
      end
    end
  end
end
