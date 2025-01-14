defmodule Bright.CareerGroupCareerFieldFactory do
  @moduledoc """
  Factory for Bright.CareerGroups.CareerGroupCareerField
  """

  defmacro __using__(_opts) do
    quote do
      def career_group_career_field_factory do
        %Bright.CareerGroups.CareerGroupCareerField{}
      end
    end
  end
end
