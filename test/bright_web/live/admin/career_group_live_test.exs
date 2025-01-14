defmodule BrightWeb.CareerGroupLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs %{
    name: "some name",
    type: "engineer",
    position: 1
  }
  @update_attrs %{
    name: "some updated name",
    type: "medical",
    position: 2
  }
  @invalid_attrs %{name: nil, type: "engineer", position: nil}

  defp create_career_group(_) do
    career_group = insert(:career_group)
    %{career_group: career_group}
  end

  describe "Index" do
    setup [:create_career_group]

    test "lists all career_groups", %{conn: conn, career_group: career_group} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/career_groups")

      assert html =~ "Listing Career groups"
      assert html =~ career_group.name
    end

    test "saves new career_group", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_groups")

      assert index_live |> element("a", "New Career group") |> render_click() =~
               "New Career group"

      assert_patch(index_live, ~p"/admin/career_groups/new")

      assert index_live
             |> form("#career_group-form", career_group: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#career_group-form", career_group: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_groups")

      html = render(index_live)
      assert html =~ "Career group created successfully"
      assert html =~ "some name"
    end

    test "updates career_group in listing", %{conn: conn, career_group: career_group} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_groups")

      assert index_live
             |> element("#career_groups-#{career_group.id} a", "Edit")
             |> render_click() =~
               "Edit Career group"

      assert_patch(index_live, ~p"/admin/career_groups/#{career_group}/edit")

      assert index_live
             |> form("#career_group-form", career_group: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#career_group-form", career_group: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_groups")

      html = render(index_live)
      assert html =~ "Career group updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes career_group in listing", %{conn: conn, career_group: career_group} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_groups")

      assert index_live
             |> element("#career_groups-#{career_group.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#career_groups-#{career_group.id}")
    end
  end

  describe "Show" do
    setup [:create_career_group]

    test "displays career_group", %{conn: conn, career_group: career_group} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/career_groups/#{career_group}")

      assert html =~ "Show Career group"
      assert html =~ career_group.name
    end

    test "updates career_group within modal", %{conn: conn, career_group: career_group} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/career_groups/#{career_group}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Career group"

      assert_patch(show_live, ~p"/admin/career_groups/#{career_group}/show/edit")

      assert show_live
             |> form("#career_group-form", career_group: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#career_group-form", career_group: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/career_groups/#{career_group}")

      html = render(show_live)
      assert html =~ "Career group updated successfully"
      assert html =~ "some updated name"
    end
  end
end
