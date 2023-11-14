defmodule Bright.InterviewMemberFactory do
  @moduledoc """
  Factory for Bright.Recruits.InterviewMember
  """

  defmacro __using__(_opts) do
    quote do
      def interview_member_factory do
        %Bright.Recruits.InterviewMember{
          decision: :not_answered
        }
      end
    end
  end
end
