defmodule Bright.CoordinationMemberFactory do
  @moduledoc """
  Factory for Bright.Recruits.CoordinationwMember
  """

  defmacro __using__(_opts) do
    quote do
      def coordination_member_factory do
        %Bright.Recruits.CoordinationMember{
          decision: :not_answered
        }
      end
    end
  end
end
