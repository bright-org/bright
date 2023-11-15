defmodule BrightWeb.TeamLive.MyTeamTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

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
      {:ok, lv, _html} = live(conn, ~p"/teams/#{custom_group}?type=custom_group")

      assert has_element?(lv, "h3", custom_group.name)
      assert has_element?(lv, "#skill_card_0", user.name)
      assert has_element?(lv, "#skill_card_0", "#{floor(skill_class_score_1.percentage)}")
      assert has_element?(lv, "#skill_card_1", user_2.name)
      assert has_element?(lv, "#skill_card_1", "#{floor(skill_class_score_2.percentage)}")
    end
  end
end
