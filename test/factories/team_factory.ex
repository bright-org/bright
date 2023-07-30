defmodule Bright.TeamFactory do
  @moduledoc """
  Factory for Bright.Teams.Team
  """

  defmacro __using__(_opts) do
    quote do
      def team_factory do
        %Bright.Teams.Team{
          name: Faker.Lorem.word()
        }
      end
    end
  end
end
