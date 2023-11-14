defmodule Bright.InterviewFactory do
  @moduledoc """
  Factory for Bright.Recruits.Interview
  """

  defmacro __using__(_opts) do
    quote do
      def interview_factory do
        %Bright.Recruits.Interview{
          skill_params: "some skill_params",
          status: :waiting_decision,
          comment: "some comment"
        }
      end
    end
  end
end
