defmodule Bright.NotificationEvidenceFactory do
  @moduledoc """
  Factory for Bright.Notifications.NotificationEvidenceFactory
  """

  defmacro __using__(_opts) do
    quote do
      def notification_notification_factory do
        %Bright.Notifications.NotificationEvidence{
          from_user: build(:user),
          to_user: build(:user),
          message: Faker.Lorem.word() <> "_#{System.unique_integer()}",
          url: Facker.Internet.url()
        }
      end
    end
  end
end
