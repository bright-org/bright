defmodule Bright.CustomGroupFactory do
  @moduledoc """
  Factory for Bright.CustomGroups.CustomGroup
  """

  defmacro __using__(_opts) do
    quote do
      def custom_group_factory do
        %Bright.CustomGroups.CustomGroup{
          name: sequence(:name, &"#{Faker.Lorem.word()}_#{&1}")
        }
      end
    end
  end
end
