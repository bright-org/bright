defmodule Bright.CareerFieldJobFactory do
  @moduledoc """
  Factory for Bright.CareerFields.CareerFieldJob
  """

  defmacro __using__(_opts) do
    quote do
      def career_field_job_factory do
        %Bright.CareerFields.CareerFieldJob{}
      end
    end
  end
end
