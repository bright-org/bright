defmodule Bright.CareerWantJobFactory do
  @moduledoc """
  Factory for Bright.CareerWants.CareerWantJob
  """

  defmacro __using__(_opts) do
    quote do
      def career_want_job_factory do
        %Bright.CareerWants.CareerWantJob{}
      end
    end
  end
end
