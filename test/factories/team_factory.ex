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

      def hr_support_team_factory do
        %Bright.Teams.Team{
          name: Faker.Lorem.word(),
          enable_hr_functions: true,
          enable_team_up_functions: true
        }
      end

      def teamup_team_factory do
        %Bright.Teams.Team{
          name: Faker.Lorem.word(),
          enable_hr_functions: false,
          enable_team_up_functions: true
        }
      end

      def undefined_team_factory do
        # HR機能のみ利用可(現状のプラン設計では存在しないパターンのチーム)
        %Bright.Teams.Team{
          name: Faker.Lorem.word(),
          enable_hr_functions: true,
          enable_team_up_functions: false
        }
      end
    end
  end
end
