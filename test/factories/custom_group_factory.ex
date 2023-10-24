defmodule Bright.CustomGroupFactory do
  @moduledoc """
  Factory for Bright.CustomGroups.CustomGroup
  """

  defmacro __using__(_opts) do
    quote do
      def custom_group_factory do
        %Bright.CustomGroups.CustomGroup{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
