defmodule Bright.NotificationOfficialTeamFactory do
  @moduledoc """
  Factory for Bright.Notifications.Notification
  """

  defmacro __using__(_opts) do
    quote do
      def notification_official_team_factory do
        %Bright.Notifications.NotificationOfficialTeam{
          message: Faker.Lorem.word(),
          detail: Faker.Lorem.word(),
          from_user: build(:user),
          to_user: build(:user),
          participation: true
        }
      end
    end
  end
end
