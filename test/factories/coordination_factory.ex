defmodule Bright.CoordinationFactory do
  @moduledoc """
  Factory for Bright.Recruits.Coordination
  """

  defmacro __using__(_opts) do
    quote do
      def coordination_factory do
        %Bright.Recruits.Coordination{
          skill_params: "some skill_params",
          status: :waiting_recruit_decision,
          comment: "some comment"
        }
      end
    end
  end
end
