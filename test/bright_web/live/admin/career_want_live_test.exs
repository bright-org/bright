defmodule BrightWeb.Admin.CareerWantLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.JobsFixtures

  @create_attrs %{name: "some name", position: 42}
  @update_attrs %{name: "some updated name", position: 43}
  @invalid_attrs %{name: nil, position: nil}

  defp create_career_want(_) do
    career_want = career_want_fixture()
    %{career_want: career_want}
  end

  describe "Index" do
    setup [:create_career_want]

    test "lists all career_wants", %{conn: conn, career_want: career_want} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/career_wants")

      assert html =~ "Listing Career wants"
      assert html =~ career_want.name
    end

    test "saves new career_want", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_wants")

      assert index_live |> element("a", "New Career want") |> render_click() =~
               "New Career want"

      assert_patch(index_live, ~p"/admin/career_wants/new")

      assert index_live
             |> form("#career_want-form", career_want: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#career_want-form", career_want: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_wants")

      html = render(index_live)
      assert html =~ "Career want created successfully"
      assert html =~ "some name"
    end

    test "updates career_want in listing", %{conn: conn, career_want: career_want} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_wants")

      assert index_live |> element("#career_wants-#{career_want.id} a", "Edit") |> render_click() =~
               "Edit Career want"

      assert_patch(index_live, ~p"/admin/career_wants/#{career_want}/edit")

      assert index_live
             |> form("#career_want-form", career_want: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#career_want-form", career_want: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_wants")

      html = render(index_live)
      assert html =~ "Career want updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes career_want in listing", %{conn: conn, career_want: career_want} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_wants")

      assert index_live
             |> element("#career_wants-#{career_want.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#career_wants-#{career_want.id}")
    end
  end

  describe "Show" do
    setup [:create_career_want]

    test "displays career_want", %{conn: conn, career_want: career_want} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/career_wants/#{career_want}")

      assert html =~ "Show Career want"
      assert html =~ career_want.name
    end

    test "updates career_want within modal", %{conn: conn, career_want: career_want} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/career_wants/#{career_want}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Career want"

      assert_patch(show_live, ~p"/admin/career_wants/#{career_want}/show/edit")

      assert show_live
             |> form("#career_want-form", career_want: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#career_want-form", career_want: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/career_wants/#{career_want}")

      html = render(show_live)
      assert html =~ "Career want updated successfully"
      assert html =~ "some updated name"
    end
  end
end
