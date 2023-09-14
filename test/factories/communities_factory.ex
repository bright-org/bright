defmodule Bright.CommunityFactory do
  @moduledoc """
  Factory for Bright.Communities.Community
  """

  defmacro __using__(_opts) do
    quote do
      def community_factory do
        %Bright.Notifications.NotificationCommunity{
          name: Faker.Lorem.word(),
          user_id: build(:user),
          community_id: build(:notification_community),
          participation: true
        }
      end
    end
  end
end
