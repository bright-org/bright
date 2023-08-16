defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [:register_and_log_in_user]

    test "view mypages", %{conn: conn, user: user} do
      {:ok, index_live, html} = live(conn, ~p"/mypage")

      assert html =~ "マイページ"

      # プロフィールの検証
      assert index_live |> has_element?("div .text-2xl.font-bold", user.name)
      assert index_live |> has_element?("div .text-2xl", user.user_profile.title)
      assert index_live |> has_element?("div .pt-5", user.user_profile.detail)
      # SNSアイコン表示
      assert index_live
             |> has_element?(
               "div.flex.gap-x-6.mr-2 button:nth-child(1) img[src='/images/common/twitter.svg']"
             )

      assert index_live
             |> has_element?(
               "div.flex.gap-x-6.mr-2 button:nth-child(2) img[src='/images/common/github.svg']"
             )

      assert index_live
             |> has_element?(
               "div.flex.gap-x-6.mr-2 button:nth-child(3) img[src='/images/common/facebook.svg']"
             )

      # スキルセットジェムのタグがあることを確認
      # TODO α版では実装しない
      # assert index_live |> has_element?("div #skill-gem")

      # 各カードがあることを確認（コンポーネントが貼られていることのみを確認）
      assert index_live |> has_element?("h5", "重要な連絡")
      assert index_live |> has_element?("li a", "チーム招待")

      assert index_live |> has_element?("h5", "保有スキル（ジェムをクリックすると成長グラフが見れます）")
      assert index_live |> has_element?("li a", "エンジニア")

      assert index_live |> has_element?("h5", "さまざまな人たちとの交流")
      assert index_live |> has_element?("li a", "スキルアップ")

      assert index_live |> has_element?("h5", "関わっているチーム")
      assert index_live |> has_element?("li a", "所属チーム")

      assert index_live |> has_element?("h5", "関わっているユーザー")
      assert index_live |> has_element?("li a", "チーム")
    end
  end
end
