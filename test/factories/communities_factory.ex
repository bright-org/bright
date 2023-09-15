defmodule Bright.CommunityFactory do
  @moduledoc """
  Factory for Bright.Communities.Community
  """

  defmacro __using__(_opts) do
    quote do
      def community_factory do
        %Bright.Communities.Community{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
