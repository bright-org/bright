defmodule Bright.CareerWantFactory do
  @moduledoc """
  Factory for Bright.CareerWants.CareerWant
  """

  defmacro __using__(_opts) do
    quote do
      def career_want_factory do
        %Bright.CareerWants.CareerWant{
          name: "Webアプリを作りたい",
          position: 42
        }
      end
    end
  end
end
