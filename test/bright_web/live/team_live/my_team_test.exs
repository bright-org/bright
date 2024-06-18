defmodule BrightWeb.TeamLive.MyTeamTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  import Mock

  describe "my team" do
    setup [:register_and_log_in_user]

    test "show my team", %{
      user: user,
      conn: conn
    } do
      insert(:subscription_user_plan_subscribing_without_free_trial, user: user)
      assert {:ok, _my_team_live, html} = live(conn, ~p"/teams")

      # TODO 表示のみ確認
      assert html =~ "チームスキル分析"
    end

    test "show my team without plan", %{
      conn: conn
    } do
      assert {:ok, _my_team_live, html} = live(conn, ~p"/teams")

      # TODO 表示のみ確認
      assert html =~ "チームスキル分析"
    end
  end

  # スキルカード「この人と比較」
  describe "Skill card link to compare on graphs" do
    setup [:register_and_log_in_user]

    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{user: user} do
      user_2 = insert(:user) |> with_user_profile()

      team = insert(:team)
      insert(:team_member_users, team: team, user: user, is_admin: true)
      insert(:team_member_users, team: team, user: user_2)

      %{team: team, user_2: user_2}
    end

    test "displays on other user card and links to /graphs", %{
      conn: conn,
      team: team,
      skill_panel: skill_panel,
      skill_class: skill_class,
      user: user,
      user_2: user_2
    } do
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user_2)
      insert(:skill_class_score, skill_class: skill_class, user: user_2)

      with_mock Bright.Utils.Aes.Aes128,
        encrypt: fn x -> x end do
        assert {:ok, lv, _html} = live(conn, ~p"/teams/#{team}/skill_panels/#{skill_panel}")

        # 自分自身に表示しない
        refute has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user.id)}",
                 "この人と比較"
               )

        # 他者に表示する
        assert has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user_2.id)}",
                 "この人と比較"
               )
      end
    end

    test "not displays when user(me) has not skill panel", %{
      conn: conn,
      team: team,
      skill_panel: skill_panel,
      skill_class: skill_class,
      user_2: user_2
    } do
      # 自分自身が未取得のスキルパネルならリンクを表示しない
      insert(:user_skill_panel, skill_panel: skill_panel, user: user_2)
      insert(:skill_class_score, skill_class: skill_class, user: user_2)

      assert {:ok, lv, _html} = live(conn, ~p"/teams/#{team}/skill_panels/#{skill_panel}")
      refute has_element?(lv, "#skill_card_0", "この人と比較")
      refute has_element?(lv, "#skill_card_1", "この人と比較")
    end

    test "not displays when other user has not skill score", %{
      conn: conn,
      team: team,
      skill_panel: skill_panel,
      user: user
    } do
      # 他者が未取得のスキルパネルならリンクを表示しない
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)

      assert {:ok, lv, _html} = live(conn, ~p"/teams/#{team}/skill_panels/#{skill_panel}")
      refute has_element?(lv, "#skill_card_0", "この人と比較")
      refute has_element?(lv, "#skill_card_1", "この人と比較")
    end
  end

  # カスタムグループ指定時表示
  describe "Custom Group" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      user_2 = insert(:user) |> with_user_profile()
      custom_group = insert(:custom_group, user: user)
      insert(:custom_group_member_user, custom_group: custom_group, user: user_2)
      team = insert(:team)
      Enum.each([user, user_2], &insert(:team_member_users, team: team, user: &1))

      %{custom_group: custom_group, users: [user, user_2]}
    end

    setup %{users: users} do
      skill_panel = insert(:skill_panel)
      Enum.each(users, &insert(:user_skill_panel, user: &1, skill_panel: skill_panel))

      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      skill_class_scores =
        Enum.map(users, fn user ->
          insert(:skill_class_score, user: user, skill_class: skill_class)
        end)

      %{skill_panel: skill_panel, skill_class_scores: skill_class_scores}
    end

    test "shows given custom group", %{
      conn: conn,
      custom_group: custom_group,
      users: [user, user_2],
      skill_class_scores: [skill_class_score_1, skill_class_score_2]
    } do
      with_mock Bright.Utils.Aes.Aes128,
        encrypt: fn x -> x end do
        {:ok, lv, _html} = live(conn, ~p"/teams/#{custom_group}")

        assert has_element?(lv, "h3", custom_group.name)

        assert has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user.id)}",
                 user.name
               )

        assert has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user.id)}",
                 "#{floor(skill_class_score_1.percentage)}"
               )

        assert has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user_2.id)}",
                 user_2.name
               )

        assert has_element?(
                 lv,
                 "#skill_card_#{Bright.Utils.Aes.Aes128.encrypt(user_2.id)}",
                 "#{floor(skill_class_score_2.percentage)}"
               )
      end
    end
  end

  # スキルカード「1on1に誘う」
  describe "Skill card link to 1on1" do
    setup [:register_and_log_in_user]

    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{user: user} do
      subscription =
        insert(:subscription_plans)
        |> plan_with_plan_service_by_service_code("hr_basic")

      subscription_user_plan_subscribing_without_free_trial(user, subscription)

      user_2 = insert(:user) |> with_user_profile()
      insert(:user_job_profile, user: user_2)

      team = insert(:team)
      insert(:team_member_users, team: team, user: user, is_admin: true)
      insert(:team_member_users, team: team, user: user_2)

      %{team: team, user_2: user_2}
    end

    test "create interview and chat when 1on1 start", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class,
      user: user,
      user_2: user_2
    } do
      insert(:user_skill_panel, skill_panel: skill_panel, user: user)
      insert(:user_skill_panel, skill_panel: skill_panel, user: user_2)
      insert(:skill_class_score, skill_class: skill_class, user: user_2)

      assert {:ok, lv, _html} = live(conn, ~p"/teams") |> follow_redirect(conn)

      assert {:ok, _lv, html} =
               lv
               |> element("button", "1on1に誘う")
               |> render_click()
               |> follow_redirect(conn)

      assert %{status: :one_on_one} = Bright.Recruits.get_interview(user.id, user_2.id)

      # 面談チャットに移動している
      assert html =~ "面談チャット"
      # 匿名が解除されている
      assert html =~ user_2.name
      # 面談の打診が可能
      assert html =~ "面談の打診"
    end
  end

  describe "my team skill_star_button" do
    setup [:register_and_log_in_user]

    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{user: user} do
      user_2 = insert(:user) |> with_user_profile()

      team = insert(:team)
      insert(:team_member_users, team: team, user: user, is_admin: true)
      insert(:team_member_users, team: team, user: user_2)

      %{team: team, user_2: user_2}
    end

    test "click skill_star_button ", %{
      user: user,
      conn: conn,
      team: team,
      skill_panel: skill_panel
    } do
      insert(:subscription_user_plan_subscribing_without_free_trial, user: user)
      assert {:ok, lv, _html} = live(conn, ~p"/teams/#{team.id}/skill_panels/#{skill_panel.id}")

      assert element(lv, "#skill_star_button") |> render() =~
               ~r{class=".*border-brightGray-500.*"}

      element(lv, "#skill_star_button") |> render_click()

      assert {:ok, lv, _html} = live(conn, ~p"/teams/#{team.id}/skill_panels/#{skill_panel.id}")

      assert element(lv, "#skill_star_button") |> render() =~
               ~r{class=".*border-brightGreen-300.*"}
    end
  end

  describe "my team not skill_star_button" do
    setup [:register_and_log_in_user]

    test "show my team", %{
      user: user,
      conn: conn
    } do
      insert(:subscription_user_plan_subscribing_without_free_trial, user: user)
      assert {:ok, lv, _html} = live(conn, ~p"/teams")

      refute has_element?(lv, "#skill_star_button")
    end
  end
end
