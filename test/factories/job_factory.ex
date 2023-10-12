defmodule Bright.JobFactory do
  @moduledoc """
  Factory for Bright.Jobs.Job
  """

  defmacro __using__(_opts) do
    quote do
      def job_factory do
        %Bright.Jobs.Job{
          name: "some job",
          rank: "basic",
          description: "some description",
          position: 42
        }
      end
    end
  end
end
