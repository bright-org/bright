defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [:register_and_log_in_user]

    test "view mypages", %{conn: conn} do
      {:ok, index_live, html} = live(conn, ~p"/mypage")

     assert html =~ "マイページ"

      assert index_live |> has_element?("h5", "重量な連絡")
      assert index_live |> has_element?("li a", "チーム招待")

      assert index_live |> has_element?("h5", "保有スキル（ジェムをクリックすると成長グラフが見れます）")
      assert index_live |> has_element?("li a", "エンジニア")

      assert index_live |> has_element?("h5", "さまざまな人たちとの交流")
      assert index_live |> has_element?("li a", "スキルアップ")

      assert index_live |> has_element?("h5", "関わっているチーム")
      assert index_live |> has_element?("li a", "所属チーム")

      assert index_live |> has_element?("h5", "関わっているユーザー")
      assert index_live |> has_element?("li a", "気になる人")

    end
  end
end
