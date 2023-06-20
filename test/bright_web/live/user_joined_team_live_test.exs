defmodule BrightWeb.UserJoinedTeamLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.TeamsFixtures

  @create_attrs %{bright_user_id: 42, team_id: 42, is_auther: true, is_primary_team: true}
  @update_attrs %{bright_user_id: 43, team_id: 43, is_auther: false, is_primary_team: false}
  @invalid_attrs %{bright_user_id: nil, team_id: nil, is_auther: false, is_primary_team: false}

  defp create_user_joined_team(_) do
    user_joined_team = user_joined_team_fixture()
    %{user_joined_team: user_joined_team}
  end

  describe "Index" do
    setup [:create_user_joined_team]

    test "lists all user_joined_teams", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/user_joined_teams")

      assert html =~ "Listing User joined teams"
    end

    test "saves new user_joined_team", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/user_joined_teams")

      assert index_live |> element("a", "New User joined team") |> render_click() =~
               "New User joined team"

      assert_patch(index_live, ~p"/user_joined_teams/new")

      assert index_live
             |> form("#user_joined_team-form", user_joined_team: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_joined_team-form", user_joined_team: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/user_joined_teams")

      html = render(index_live)
      assert html =~ "User joined team created successfully"
    end

    test "updates user_joined_team in listing", %{conn: conn, user_joined_team: user_joined_team} do
      {:ok, index_live, _html} = live(conn, ~p"/user_joined_teams")

      assert index_live |> element("#user_joined_teams-#{user_joined_team.id} a", "Edit") |> render_click() =~
               "Edit User joined team"

      assert_patch(index_live, ~p"/user_joined_teams/#{user_joined_team}/edit")

      assert index_live
             |> form("#user_joined_team-form", user_joined_team: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#user_joined_team-form", user_joined_team: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/user_joined_teams")

      html = render(index_live)
      assert html =~ "User joined team updated successfully"
    end

    test "deletes user_joined_team in listing", %{conn: conn, user_joined_team: user_joined_team} do
      {:ok, index_live, _html} = live(conn, ~p"/user_joined_teams")

      assert index_live |> element("#user_joined_teams-#{user_joined_team.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#user_joined_teams-#{user_joined_team.id}")
    end
  end

  describe "Show" do
    setup [:create_user_joined_team]

    test "displays user_joined_team", %{conn: conn, user_joined_team: user_joined_team} do
      {:ok, _show_live, html} = live(conn, ~p"/user_joined_teams/#{user_joined_team}")

      assert html =~ "Show User joined team"
    end

    test "updates user_joined_team within modal", %{conn: conn, user_joined_team: user_joined_team} do
      {:ok, show_live, _html} = live(conn, ~p"/user_joined_teams/#{user_joined_team}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit User joined team"

      assert_patch(show_live, ~p"/user_joined_teams/#{user_joined_team}/show/edit")

      assert show_live
             |> form("#user_joined_team-form", user_joined_team: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#user_joined_team-form", user_joined_team: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/user_joined_teams/#{user_joined_team}")

      html = render(show_live)
      assert html =~ "User joined team updated successfully"
    end
  end
end
