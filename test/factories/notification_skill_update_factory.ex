defmodule Bright.NotificationSkillUpdateFactory do
  @moduledoc """
  Factory for Bright.Notifications.NotificationSkillUpdateFactory
  """

  defmacro __using__(_opts) do
    quote do
      def notification_skill_update_factory do
        %Bright.Notifications.NotificationSkillUpdate{
          from_user: build(:user),
          to_user: build(:user),
          message: Faker.Lorem.word() <> "_#{System.unique_integer()}",
          url: Faker.Internet.url()
        }
      end
    end
  end
end
