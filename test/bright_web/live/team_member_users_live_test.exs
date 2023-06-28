defmodule BrightWeb.TeamMemberUsersLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.TeamsFixtures

  @create_attrs %{is_admin: true, is_primary: true, team_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662"}
  @update_attrs %{is_admin: false, is_primary: false, team_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668"}
  @invalid_attrs %{is_admin: false, is_primary: false, team_id: nil, user_id: nil}

  defp create_team_member_users(_) do
    team_member_users = team_member_users_fixture()
    %{team_member_users: team_member_users}
  end

  describe "Index" do
    setup [:create_team_member_users]

    test "lists all team_member_users", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/team_member_users")

      assert html =~ "Listing Team member users"
    end

    test "saves new team_member_users", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/team_member_users")

      assert index_live |> element("a", "New Team member users") |> render_click() =~
               "New Team member users"

      assert_patch(index_live, ~p"/team_member_users/new")

      assert index_live
             |> form("#team_member_users-form", team_member_users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#team_member_users-form", team_member_users: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/team_member_users")

      html = render(index_live)
      assert html =~ "Team member users created successfully"
    end

    test "updates team_member_users in listing", %{conn: conn, team_member_users: team_member_users} do
      {:ok, index_live, _html} = live(conn, ~p"/team_member_users")

      assert index_live |> element("#team_member_users-#{team_member_users.id} a", "Edit") |> render_click() =~
               "Edit Team member users"

      assert_patch(index_live, ~p"/team_member_users/#{team_member_users}/edit")

      assert index_live
             |> form("#team_member_users-form", team_member_users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#team_member_users-form", team_member_users: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/team_member_users")

      html = render(index_live)
      assert html =~ "Team member users updated successfully"
    end

    test "deletes team_member_users in listing", %{conn: conn, team_member_users: team_member_users} do
      {:ok, index_live, _html} = live(conn, ~p"/team_member_users")

      assert index_live |> element("#team_member_users-#{team_member_users.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#team_member_users-#{team_member_users.id}")
    end
  end

  describe "Show" do
    setup [:create_team_member_users]

    test "displays team_member_users", %{conn: conn, team_member_users: team_member_users} do
      {:ok, _show_live, html} = live(conn, ~p"/team_member_users/#{team_member_users}")

      assert html =~ "Show Team member users"
    end

    test "updates team_member_users within modal", %{conn: conn, team_member_users: team_member_users} do
      {:ok, show_live, _html} = live(conn, ~p"/team_member_users/#{team_member_users}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Team member users"

      assert_patch(show_live, ~p"/team_member_users/#{team_member_users}/show/edit")

      assert show_live
             |> form("#team_member_users-form", team_member_users: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#team_member_users-form", team_member_users: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/team_member_users/#{team_member_users}")

      html = render(show_live)
      assert html =~ "Team member users updated successfully"
    end
  end
end
