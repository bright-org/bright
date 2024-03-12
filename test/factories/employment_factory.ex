defmodule Bright.EmploymentFactory do
  @moduledoc """
  Factory for Bright.Recruits.Employment
  """

  defmacro __using__(_opts) do
    quote do
      def employment_factory do
        %Bright.Recruits.Employment{
          skill_params: "some skill_params",
          desired_income: 10000,
          status: :waiting_responce,
          comment: "some comment",
          income: 10000,
          message: "hire you",
          used_sample: :none,
          employment_status: :employee
        }
      end
    end
  end
end
