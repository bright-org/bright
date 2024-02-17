defmodule Bright.TeamJoinRequestFactory do
  @moduledoc """
  Factory for Bright.Recruits.TeamJoinRequest
  """

  defmacro __using__(_opts) do
    quote do
      def team_join_request_factory do
        %Bright.Recruits.TeamJoinRequest{
          comment: "some comment",
          status: :requested
        }
      end
    end
  end
end
