defmodule BrightWeb.TeamLive.MyTeamTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "my team" do
    setup [:register_and_log_in_user]

    test "show my team", %{
      user: user,
      conn: conn
    } do
      insert(:subscription_user_plan_subscribing_without_free_trial, user: user)
      assert {:ok, _my_team_live, html} = live(conn, ~p"/teams")

      # TODO 表示のみ確認
      assert html =~ "チームスキル分析"
    end
  end
end
