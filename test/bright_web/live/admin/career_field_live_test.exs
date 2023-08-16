defmodule BrightWeb.Admin.CareerFieldLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.JobsFixtures

  @create_attrs %{
    name_en: "some name",
    name_ja: "日本語名",
    position: 42
  }
  @update_attrs %{
    name_en: "some updated name",
    name_ja: "更新された日本語名",
    position: 43
  }
  @invalid_attrs %{name_en: nil, name_ja: nil, position: nil}

  defp create_career_field(_) do
    career_field = career_field_fixture()
    %{career_field: career_field}
  end

  describe "Index" do
    setup [:create_career_field]

    test "lists all career_fields", %{conn: conn, career_field: career_field} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/career_fields")

      assert html =~ "Listing Career fields"
      assert html =~ career_field.name_en
    end

    test "saves new career_field", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_fields")

      assert index_live |> element("a", "New Career field") |> render_click() =~
               "New Career field"

      assert_patch(index_live, ~p"/admin/career_fields/new")

      assert index_live
             |> form("#career_field-form", career_field: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#career_field-form", career_field: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_fields")

      html = render(index_live)
      assert html =~ "Career field created successfully"
      assert html =~ "some name"
    end

    test "updates career_field in listing", %{conn: conn, career_field: career_field} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_fields")

      assert index_live
             |> element("#career_fields-#{career_field.id} a", "Edit")
             |> render_click() =~
               "Edit Career field"

      assert_patch(index_live, ~p"/admin/career_fields/#{career_field}/edit")

      assert index_live
             |> form("#career_field-form", career_field: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#career_field-form", career_field: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/career_fields")

      html = render(index_live)
      assert html =~ "Career field updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes career_field in listing", %{conn: conn, career_field: career_field} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/career_fields")

      assert index_live
             |> element("#career_fields-#{career_field.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#career_fields-#{career_field.id}")
    end
  end

  describe "Show" do
    setup [:create_career_field]

    test "displays career_field", %{conn: conn, career_field: career_field} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/career_fields/#{career_field}")

      assert html =~ "Show Career field"
      assert html =~ career_field.name_en
    end

    test "updates career_field within modal", %{conn: conn, career_field: career_field} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/career_fields/#{career_field}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Career field"

      assert_patch(show_live, ~p"/admin/career_fields/#{career_field}/show/edit")

      assert show_live
             |> form("#career_field-form", career_field: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#career_field-form", career_field: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/career_fields/#{career_field}")

      html = render(show_live)
      assert html =~ "Career field updated successfully"
      assert html =~ "some updated name"
    end
  end
end
