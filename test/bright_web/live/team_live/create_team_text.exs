defmodule BrightWeb.TeamLive.CreateTeamTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "create_team" do
    setup [:register_and_log_in_user]

    test "show create team view and user_add botton", %{
      conn: conn
    } do
      assert {:ok, create_team_live, html} = live(conn, ~p"/teams/new")

      assert html =~ "チーム作成"

      member_user = insert(:user)

      add_user_result =
        create_team_live
        |> element("#add_user_form")
        |> render_submit(%{search_word: member_user.name})

      # 一時メンバーリストにユーザーが追加された事（現状はnameしか表示項目がない）
      assert add_user_result =~ member_user.name
    end

    test "show create team view and create team botton", %{
      conn: conn
    } do
      assert {:ok, create_team_live, html} = live(conn, ~p"/teams/new")

      assert html =~ "チーム作成"

      team_name = Faker.Lorem.word()

      assert {:ok, conn} =
               create_team_live
               |> element("#create_team_form")
               |> render_submit(%{team_name: team_name})
               |> follow_redirect(conn, "/mypage")

      # マイページへ遷移後チーム名が追加表示されていること
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "チームを登録しました"

      assert conn.resp_body =~ team_name
    end
  end
end
