defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [:register_and_log_in_user]

    test "view mypages", %{conn: conn, user: user} do
      {:ok, index_live, html} = live(conn, ~p"/mypage")

      assert html =~ "マイページ"

      #ページヘッダー
      assert index_live |> has_element?("button", "プランのアップグレード")
      assert index_live |> has_element?("button", "カスタマーサクセスに連絡")
      assert index_live |> has_element?("button", "スキル保有者を検索")
      #ユーザーアイコン
      assert index_live |> has_element?("button img.inline-block.h-10.w-10.rounded-full")
      #ログアウト
      assert index_live |> has_element?("a button span", "logout")

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

      assert index_live |> has_element?("li a", "運営")

      ["チーム招待", "振り返り", "採用の調整", "運営"]
      |> Enum.each(fn x -> assert_tab(x, index_live) end)

      assert index_live |> has_element?("h5", "保有スキル（ジェムをクリックすると成長グラフが見れます）")
      # assert index_live |> has_element?("li a", "インフラ")

      assert index_live |> has_element?("h5", "さまざまな人たちとの交流")

      ["スキルアップ", "祝福された", "1on1のお誘い", "推し活", "気になる", "コミュニティ"]
      |> Enum.each(fn x -> assert_tab(x, index_live) end)

      assert index_live |> has_element?("h5", "関わっているチーム")

      ["所属チーム", "採用・育成チーム", "採用・育成支援先"]
      |> Enum.each(fn x -> assert_tab(x, index_live) end)

      assert index_live |> has_element?("h5", "関わっているユーザー")

      ["気になる人", "チーム", "採用候補者"]
      |> Enum.each(fn x -> assert_tab(x, index_live) end)
    end
  end

  defp assert_tab(tab_name, live), do: assert(has_element?(live, "li a", tab_name))
end
