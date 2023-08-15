defmodule Bright.CareerFieldFactory do
  @moduledoc """
  Factory for Bright.CareerFields.CareerField
  """

  defmacro __using__(_opts) do
    quote do
      def career_field_factory do
        %Bright.CareerFields.CareerField{
          name_en: "engineer",
          name_ja: "エンジニア",
          position: 42
        }
      end
    end
  end
end
