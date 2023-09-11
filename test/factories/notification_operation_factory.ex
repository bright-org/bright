defmodule Bright.NotificationOperationFactory do
  @moduledoc """
  Factory for Bright.Notifications.NotificationOperationFactory
  """

  defmacro __using__(_opts) do
    quote do
      def notification_operation_factory do
        %Bright.Notifications.NotificationOperation{
          from_user: build(:user),
          message: Faker.Lorem.word(),
          detail: Faker.Lorem.word()
        }
      end
    end
  end
end
