defmodule Bright.TeamMemberUsersFactory do
  @moduledoc """
  Factory for Bright.Teams.TeamMemberUsers
  """

  defmacro __using__(_opts) do
    quote do
      def team_member_users_factory do
        %Bright.Teams.TeamMemberUsers{
          user: build(:user),
          invitation_confirmed_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
        }
      end

      def team_member_users_unconfirmed_factory do
        %Bright.Teams.TeamMemberUsers{
          user: build(:user),
          invitation_confirmed_at: nil
        }
      end
    end
  end
end
