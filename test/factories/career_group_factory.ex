defmodule Bright.CareerGroupFactory do
  @moduledoc """
  Factory for Bright.CareerGroups.CareerGroup
  """

  defmacro __using__(_opts) do
    quote do
      def career_group_factory do
        %Bright.CareerGroups.CareerGroup{
          name: "Bright",
          type: "engineer",
          position: 1
        }
      end
    end
  end
end
