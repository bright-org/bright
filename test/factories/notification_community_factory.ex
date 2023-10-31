defmodule Bright.NotificationCommunityFactory do
  @moduledoc """
  Factory for Bright.Notifications.NotificationCommunity
  """

  defmacro __using__(_opts) do
    quote do
      def notification_community_factory do
        %Bright.Notifications.NotificationCommunity{
          from_user: build(:user),
          message: Faker.Lorem.word() <> "_#{System.unique_integer()}",
          detail: Faker.Lorem.word() <> "_#{System.unique_integer()}"
        }
      end
    end
  end
end
