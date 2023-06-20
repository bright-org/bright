defmodule BrightWeb.BrightUserLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.UsersFixtures

  @create_attrs %{password: "some password", handle_name: "some handle_name", email: "some email"}
  @update_attrs %{password: "some updated password", handle_name: "some updated handle_name", email: "some updated email"}
  @invalid_attrs %{password: nil, handle_name: nil, email: nil}

  defp create_bright_user(_) do
    bright_user = bright_user_fixture()
    %{bright_user: bright_user}
  end

  describe "Index" do
    setup [:create_bright_user]

    test "lists all bright_users", %{conn: conn, bright_user: bright_user} do
      {:ok, _index_live, html} = live(conn, ~p"/bright_users")

      assert html =~ "Listing Bright users"
      assert html =~ bright_user.password
    end

    test "saves new bright_user", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/bright_users")

      assert index_live |> element("a", "New Bright user") |> render_click() =~
               "New Bright user"

      assert_patch(index_live, ~p"/bright_users/new")

      assert index_live
             |> form("#bright_user-form", bright_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bright_user-form", bright_user: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bright_users")

      html = render(index_live)
      assert html =~ "Bright user created successfully"
      assert html =~ "some password"
    end

    test "updates bright_user in listing", %{conn: conn, bright_user: bright_user} do
      {:ok, index_live, _html} = live(conn, ~p"/bright_users")

      assert index_live |> element("#bright_users-#{bright_user.id} a", "Edit") |> render_click() =~
               "Edit Bright user"

      assert_patch(index_live, ~p"/bright_users/#{bright_user}/edit")

      assert index_live
             |> form("#bright_user-form", bright_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#bright_user-form", bright_user: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/bright_users")

      html = render(index_live)
      assert html =~ "Bright user updated successfully"
      assert html =~ "some updated password"
    end

    test "deletes bright_user in listing", %{conn: conn, bright_user: bright_user} do
      {:ok, index_live, _html} = live(conn, ~p"/bright_users")

      assert index_live |> element("#bright_users-#{bright_user.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#bright_users-#{bright_user.id}")
    end
  end

  describe "Show" do
    setup [:create_bright_user]

    test "displays bright_user", %{conn: conn, bright_user: bright_user} do
      {:ok, _show_live, html} = live(conn, ~p"/bright_users/#{bright_user}")

      assert html =~ "Show Bright user"
      assert html =~ bright_user.password
    end

    test "updates bright_user within modal", %{conn: conn, bright_user: bright_user} do
      {:ok, show_live, _html} = live(conn, ~p"/bright_users/#{bright_user}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Bright user"

      assert_patch(show_live, ~p"/bright_users/#{bright_user}/show/edit")

      assert show_live
             |> form("#bright_user-form", bright_user: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#bright_user-form", bright_user: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/bright_users/#{bright_user}")

      html = render(show_live)
      assert html =~ "Bright user updated successfully"
      assert html =~ "some updated password"
    end
  end
end
