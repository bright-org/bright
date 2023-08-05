defmodule Bright.CareerFieldFactory do
  @moduledoc """
  Factory for Bright.Jobs.CareerField
  """

  defmacro __using__(_opts) do
    quote do
      def career_field_factory do
        %Bright.Jobs.CareerField{
          name_en: "engineer",
          name_ja: "エンジニア",
          position: 42
        }
      end
    end
  end
end
