defmodule Bright.TeamSupporterTeamFactory do
  @moduledoc """
  Factory for Bright.Teams.TeamSupporterTeam
  """

  defmacro __using__(_opts) do
    quote do
      def team_supporter_team_factory do
        %Bright.Teams.TeamSupporterTeam{
          request_datetime: NaiveDateTime.utc_now(),
          status: :requesting
        }
      end

      def team_supporter_team_supporting_factory do
        %Bright.Teams.TeamSupporterTeam{
          request_datetime: NaiveDateTime.utc_now(),
          start_datetime: NaiveDateTime.utc_now(),
          status: :supporting
        }
      end

      def relate_user_and_supporter(user_1, user_2, status \\ :supporting) do
        # 支援関係を生成し、それぞれのチームを返す
        supportee_team = insert(:team)
        insert(:team_member_users, team: supportee_team, user: user_1)

        supporter_team = insert(:team, enable_hr_functions: true)
        insert(:team_member_users, team: supporter_team, user: user_2)

        insert(:team_supporter_team_supporting,
          supportee_team: supportee_team,
          supporter_team: supporter_team,
          request_from_user: user_1,
          request_to_user: user_2,
          status: status
        )

        {supportee_team, supporter_team}
      end
    end
  end
end
