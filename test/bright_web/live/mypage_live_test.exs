defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Index" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "view mypages", %{conn: conn, user: user} do
      {:ok, index_live, html} = live(conn, ~p"/mypage")

      assert html =~ "マイページ"

      # メニュー
      menu  = Floki.find(html, "aside div li a")
      assert Enum.any?(menu, & menu_find?(&1, "チームを作る（β）"))
      assert Enum.any?(menu, & menu_find?(&1, "マイページ"))
      assert Enum.any?(menu, & menu_find?(&1, "スキルを選ぶ"))
      assert Enum.any?(menu, & menu_find?(&1, "成長パネル"))
      assert Enum.any?(menu, & menu_find?(&1, "スキルパネル"))
      assert Enum.any?(menu, & menu_find?(&1, "チームスキル分析"))
      assert Enum.any?(menu, & menu_find?(&1, "面談チャット"))
      assert Enum.any?(menu, & menu_find?(&1, "ログアウト"))

      # プロフィールの検証
      assert index_live |> has_element?("div .font-bold", user.name)
      assert index_live |> has_element?("div .break-all", user.user_profile.title)
      assert index_live |> has_element?("div .pt-5", user.user_profile.detail)
      # SNSアイコン表示
      assert index_live
             |> has_element?("button:nth-child(1) img[src='/images/common/twitter.svg']")

      assert index_live
             |> has_element?("button:nth-child(2) img[src='/images/common/github.svg']")

      assert index_live
             |> has_element?("button:nth-child(3) img[src='/images/common/facebook.svg']")

      assert index_live |> has_element?("h5", "保有スキル（ジェムをクリック）")
      assert index_live |> has_element?("li a", "エンジニア")

      assert index_live |> has_element?("h5", "関わっているチーム")
      assert index_live |> has_element?("li a", "所属チーム")

      assert index_live |> has_element?("h5", "関わっているユーザー")
      assert index_live |> has_element?("li a", "チーム")
    end
  end

  # スキルセットジェム確認
  describe "Skillset gem" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "shows gem with data", %{
      conn: conn,
      user: user,
      career_fields: career_fields
    } do
      [career_field | _] = career_fields
      insert(:career_field_score, user: user, career_field: career_field, percentage: 10)

      {:ok, index_live, _html} = live(conn, ~p"/mypage")

      data = [[10, 0, 0, 0]] |> Jason.encode!()
      assert has_element?(index_live, ~s(#skillset-gem[data-data='#{data}']))

      data_labels = Enum.map(career_fields, & &1.name_ja) |> Jason.encode!()
      assert has_element?(index_live, ~s(#skillset-gem[data-labels='#{data_labels}']))

    end

    test "shows gem without data", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mypage")

      data = [[0, 0, 0, 0]] |> Jason.encode!()
      assert has_element?(index_live, ~s(#skillset-gem[data-data='#{data}']))
    end

    test "shows gem when display others", %{
      conn: conn,
      user: user,
      career_fields: career_fields
    } do
      user_2 = insert(:user) |> with_user_profile()
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      [career_field | _] = career_fields
      insert(:career_field_score, user: user, career_field: career_field, percentage: 10)
      insert(:career_field_score, user: user_2, career_field: career_field, percentage: 50)

      {:ok, index_live, _html} = live(conn, ~p"/mypage/#{user_2.name}")

      # dataが切り替えている対象者のものであること
      data = [[50, 0, 0, 0]] |> Jason.encode!()
      assert has_element?(index_live, ~s(#skillset-gem[data-data='#{data}']))
    end
  end

  defp menu_find?(el, menu_text) do
    text = el
    |> Tuple.to_list()
    |> Enum.at(2)
    |> Enum.at(1)
    text =~ menu_text
  end

end
