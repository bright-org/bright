defmodule BrightWeb.Admin.OnboardingWantLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.OnboardingsFixtures

  @create_attrs %{name: "some name", position: 42}
  @update_attrs %{name: "some updated name", position: 43}
  @invalid_attrs %{name: nil, position: nil}

  defp create_onboarding_want(_) do
    onboarding_want = onboarding_want_fixture()
    %{onboarding_want: onboarding_want}
  end

  describe "Index" do
    setup [:create_onboarding_want]

    test "lists all onboarding_wants", %{conn: conn, onboarding_want: onboarding_want} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/onboarding_wants")

      assert html =~ "Listing Onboarding wants"
      assert html =~ onboarding_want.name
    end

    test "saves new onboarding_want", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/onboarding_wants")

      assert index_live |> element("a", "New Onboarding want") |> render_click() =~
               "New Onboarding want"

      assert_patch(index_live, ~p"/admin/onboarding_wants/new")

      assert index_live
             |> form("#onboarding_want-form", onboarding_want: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#onboarding_want-form", onboarding_want: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/onboarding_wants")

      html = render(index_live)
      assert html =~ "Onboarding want created successfully"
      assert html =~ "some name"
    end

    test "updates onboarding_want in listing", %{conn: conn, onboarding_want: onboarding_want} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/onboarding_wants")

      assert index_live |> element("#onboarding_wants-#{onboarding_want.id} a", "Edit") |> render_click() =~
               "Edit Onboarding want"

      assert_patch(index_live, ~p"/admin/onboarding_wants/#{onboarding_want}/edit")

      assert index_live
             |> form("#onboarding_want-form", onboarding_want: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#onboarding_want-form", onboarding_want: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/onboarding_wants")

      html = render(index_live)
      assert html =~ "Onboarding want updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes onboarding_want in listing", %{conn: conn, onboarding_want: onboarding_want} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/onboarding_wants")

      assert index_live |> element("#onboarding_wants-#{onboarding_want.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#onboarding_wants-#{onboarding_want.id}")
    end
  end

  describe "Show" do
    setup [:create_onboarding_want]

    test "displays onboarding_want", %{conn: conn, onboarding_want: onboarding_want} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/onboarding_wants/#{onboarding_want}")

      assert html =~ "Show Onboarding want"
      assert html =~ onboarding_want.name
    end

    test "updates onboarding_want within modal", %{conn: conn, onboarding_want: onboarding_want} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/onboarding_wants/#{onboarding_want}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Onboarding want"

      assert_patch(show_live, ~p"/admin/onboarding_wants/#{onboarding_want}/show/edit")

      assert show_live
             |> form("#onboarding_want-form", onboarding_want: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#onboarding_want-form", onboarding_want: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/onboarding_wants/#{onboarding_want}")

      html = render(show_live)
      assert html =~ "Onboarding want updated successfully"
      assert html =~ "some updated name"
    end
  end
end
