defmodule BrightWeb.MypageLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions

  setup :set_swoosh_global

  defp create_first_skill_evidence(user) do
    skill_unit = insert(:skill_unit)
    skill_category = insert(:skill_category, skill_unit: skill_unit)
    skill = insert(:skill, skill_category: skill_category)
    skill_evidence = insert(:skill_evidence, user: user, skill: skill)
    skill_evidence
  end

  defp open_skill_evidence_modal(lv, skill_evidence) do
    lv
    |> element("button[class='link-evidence'][phx-value-id='#{skill_evidence.id}']")
    |> render_click()
  end

  describe "Index" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "view mypages", %{conn: conn, user: user} do
      {:ok, lv, html} = live(conn, ~p"/mypage")

      assert html =~ "マイページ"

      # プロフィールの検証
      assert has_element?(lv, "#profile-field", user.name)
      assert has_element?(lv, "#profile-field", user.user_profile.title)
      assert has_element?(lv, "#profile-field", user.user_profile.detail)

      # SNSアイコン表示
      assert has_element?(lv, "button:nth-child(1) img[src='/images/common/x.svg']")
      assert has_element?(lv, "button:nth-child(2) img[src='/images/common/github.svg']")
      assert has_element?(lv, "button:nth-child(3) img[src='/images/common/facebook.svg']")
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

  # スキルアップ確認
  describe "skill_ups" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "shows empty message", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/mypage")
      assert html =~ "まだスキルを選択していません"
    end
  end

  # 学習メモ確認
  describe "recent_skill_evidences" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "shows empty message", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/mypage")
      assert html =~ "まだ学習メモがありません"
    end

    test "adds new post", %{conn: conn, user: user} do
      skill_evidence = create_first_skill_evidence(user)

      insert(:skill_evidence_post,
        user: user,
        skill_evidence: skill_evidence,
        content: "最初の投稿",
        inserted_at: ~N[2024-08-01 00:00:00]
      )

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      assert has_element?(lv, "#my-field", "最初の投稿")

      # 投稿
      open_skill_evidence_modal(lv, skill_evidence)

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "新メモ"})
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts", "新メモ")

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      refute has_element?(lv, "#my-field", "最初の投稿")
      assert has_element?(lv, "#my-field", "新メモ")
    end

    test "deletes post", %{conn: conn, user: user} do
      skill_evidence = create_first_skill_evidence(user)

      post =
        insert(:skill_evidence_post, user: user, skill_evidence: skill_evidence, content: "最初の投稿")

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      assert has_element?(lv, "#my-field", "最初の投稿")

      # 投稿削除
      open_skill_evidence_modal(lv, skill_evidence)

      lv
      |> element(~s([phx-click="delete"][phx-value-id="#{post.id}"]))
      |> render_click()

      refute has_element?(lv, "#skill_evidence_posts", "最初の投稿")

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      refute has_element?(lv, "#my-field", "最初の投稿")
    end

    test "paginations", %{conn: conn, user: user} do
      # 1~11 の投稿作成
      gen_timestamps(11)
      |> Enum.with_index(1)
      |> Enum.map(fn {timestamp, i} ->
        skill_evidence = create_first_skill_evidence(user)

        insert(:skill_evidence_post,
          user: user,
          skill_evidence: skill_evidence,
          content: "投稿#{i}です",
          inserted_at: timestamp
        )
      end)

      {:ok, lv, html} = live(conn, ~p"/mypage")

      assert html =~ "投稿11です"
      assert html =~ "投稿2です"
      refute html =~ "投稿1です"

      # さらに表示
      lv
      |> element("button", "さらに表示")
      |> render_click()

      assert render(lv) =~ "投稿1です"
    end
  end

  # いま学んでいます確認
  describe "recent_others_skill_evidences" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "adds new post", %{conn: conn, user: user} do
      user_2 = insert(:user) |> with_user_profile()
      create_team_with_team_member_users([user, user_2])

      skill_evidence = create_first_skill_evidence(user_2)

      insert(:skill_evidence_post,
        user: user_2,
        skill_evidence: skill_evidence,
        content: "チームメンバーの投稿",
        inserted_at: ~N[2024-08-01 00:00:00]
      )

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      assert has_element?(lv, "#others-field", "チームメンバーの投稿")

      # 投稿
      open_skill_evidence_modal(lv, skill_evidence)

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "メモ投稿"})
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts", "メモ投稿")

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      # 持ち主の最新が表示されるので「チームメンバーの投稿」で正しい
      assert has_element?(lv, "#others-field", "チームメンバーの投稿")
      refute has_element?(lv, "#others-field", "メモ投稿")
    end

    test "deletes post", %{conn: conn, user: user} do
      user_2 = insert(:user) |> with_user_profile()
      create_team_with_team_member_users([user, user_2])

      skill_evidence = create_first_skill_evidence(user_2)

      insert(:skill_evidence_post,
        user: user_2,
        skill_evidence: skill_evidence,
        content: "チームメンバーの投稿"
      )

      post =
        insert(:skill_evidence_post, user: user, skill_evidence: skill_evidence, content: "メモ投稿")

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      assert has_element?(lv, "#others-field", "チームメンバーの投稿")

      # 投稿削除
      open_skill_evidence_modal(lv, skill_evidence)

      lv
      |> element(~s([phx-click="delete"][phx-value-id="#{post.id}"]))
      |> render_click()
    end

    test "does not show non-relation user's skill_evidence", %{conn: conn} do
      user_2 = insert(:user) |> with_user_profile()

      # 無関係なuser_2の投稿作成
      skill_evidence = create_first_skill_evidence(user_2)
      insert(:skill_evidence_post, user: user_2, skill_evidence: skill_evidence, content: "誰かの投稿")

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      refute has_element?(lv, "#others-field", "誰かの投稿")
    end
  end

  # 他者閲覧時の確認
  describe "Team member page" do
    setup [:register_and_log_in_user, :setup_career_fields]

    test "does not show others evidence_posts fields", %{
      user: user,
      conn: conn
    } do
      user_2 = insert(:user) |> with_user_profile()
      create_team_with_team_member_users([user, user_2])

      {:ok, lv, _html} = live(conn, ~p"/mypage/#{user_2.name}")

      assert has_element?(lv, "#my-field")
      refute has_element?(lv, "#others-field")
    end

    test "shows link with skill_evidence_post", %{user: user, conn: conn} do
      user_2 = insert(:user) |> with_user_profile()
      create_team_with_team_member_users([user, user_2])

      user_3 = insert(:user) |> with_user_profile()
      create_team_with_team_member_users([user_2, user_3])

      skill_evidence = create_first_skill_evidence(user_2)

      insert(:skill_evidence_post,
        user: user_3,
        skill_evidence: skill_evidence,
        content: "チームメンバーの投稿",
        inserted_at: ~N[2024-08-01 00:00:00]
      )

      # 他者マイページに出てくる無関係のチームメンバーの投稿が匿名であること
      {:ok, lv, _html} = live(conn, ~p"/mypage/#{user_2.name}")

      refute has_element?(lv, "#my-field a[href='/mypage/#{user_3.name}']")

      # 知っているメンバーならば匿名表示にならないこと
      create_team_with_team_member_users([user, user_3])

      {:ok, lv, _html} = live(conn, ~p"/mypage/#{user_2.name}")

      assert has_element?(lv, "#my-field a[href='/mypage/#{user_3.name}']")
    end
  end

  # 他者閲覧（匿名）時の確認
  describe "Anonymous user page" do
    alias BrightWeb.PathHelper

    setup [:register_and_log_in_user, :setup_career_fields]

    test "does not show others evidence_posts fields", %{
      conn: conn
    } do
      user_2 = insert(:user) |> with_user_profile()

      {:ok, lv, _html} = live(conn, PathHelper.mypage_path(user_2, true))

      assert has_element?(lv, "#my-field")
      refute has_element?(lv, "#others-field")
    end

    test "shows link with skill_evidence_post", %{user: user, conn: conn} do
      user_2 = insert(:user) |> with_user_profile()
      user_3 = insert(:user) |> with_user_profile()

      skill_evidence = create_first_skill_evidence(user_2)

      insert(:skill_evidence_post,
        user: user_3,
        skill_evidence: skill_evidence,
        content: "チームメンバーの投稿",
        inserted_at: ~N[2024-08-01 00:00:00]
      )

      # 匿名アクセス時は仮に知っているメンバーでも匿名表示になること
      # (現状の学習メモ仕様を踏襲)
      create_team_with_team_member_users([user_2, user_3])
      create_team_with_team_member_users([user, user_3])

      {:ok, lv, html} = live(conn, PathHelper.mypage_path(user_2, true))

      assert html =~ "チームメンバーの投稿"
      refute has_element?(lv, "#my-field a[href='/mypage/#{user_3.name}']")
    end
  end
end
