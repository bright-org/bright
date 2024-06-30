defmodule BrightWeb.UserSettingsLive.CurrentSubscriptionPlanComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "利用プラン" do
    setup [:register_and_log_in_user, :setup_subscription_plan]

    test "displays the subscription plan label", %{
      conn: conn,
      user: _user,
      subscription_plans: _subscription_plans
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()
      assert lv |> has_element?("#current_subscription_plan", "利用プラン")
    end

    test "displays the appropriate message when no subscription plan exists.", %{
      conn: conn,
      user: _user,
      subscription_plans: _subscription_plans
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "なし")
    end

    test "displays (無料トライアル中) when in free trial", %{
      conn: conn,
      user: user,
      subscription_plans: subscription_plans
    } do
      subscription_plan = find_subscription_plan(subscription_plans)

      subscription_user_plan_free_trial(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "みんなでワイワイ（無料トライアル中）")
    end

    test "displays the plan name when the free trial has ended", %{
      conn: conn,
      user: user,
      subscription_plans: subscription_plans
    } do
      subscription_plan = find_subscription_plan(subscription_plans)

      subscription_user_plan_free_trial_end(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "なし")
    end

    test "displays the plan name when the user subscribes after the free trial", %{
      conn: conn,
      user: user,
      subscription_plans: subscription_plans
    } do
      subscription_plan = find_subscription_plan(subscription_plans, "チームの価値を発掘")

      subscription_user_plan_subscribing_with_free_trial(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "チームの価値を発掘")
    end

    test "displays 「なし」 when the user was subscribed after the free trial but the subscription has ended",
         %{
           conn: conn,
           user: user,
           subscription_plans: subscription_plans
         } do
      subscription_plan = find_subscription_plan(subscription_plans)

      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "なし")
    end

    test "displays the plan name when the user is subscribed without a free trial",
         %{
           conn: conn,
           user: user,
           subscription_plans: subscription_plans
         } do
      subscription_plan = find_subscription_plan(subscription_plans, "みんなでワイワイ 拡張プラン")

      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "みんなでワイワイ 拡張プラン")
    end

    test "displays 「なし」 when the user was subscribed without a free trial but the subscription has ended",
         %{
           conn: conn,
           user: user,
           subscription_plans: subscription_plans
         } do
      subscription_plan = find_subscription_plan(subscription_plans)

      subscription_user_plan_subscription_end_without_free_trial(user, subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "なし")
    end

    test "displays a different plan name when a user subscribes to a different plan after their previous subscription ends.",
         %{
           conn: conn,
           user: user,
           subscription_plans: subscription_plans
         } do
      subscription_plan = find_subscription_plan(subscription_plans)

      another_subscription_plan = find_subscription_plan(subscription_plans, "誰でもダイレクト採用")

      # 契約終了したプランデータをインサート
      subscription_user_plan_subscription_end_without_free_trial(user, subscription_plan)

      # 別のプランを契約する
      subscription_user_plan_subscribing_without_free_trial(user, another_subscription_plan)

      {:ok, lv, _html} = live(conn, ~p"/mypage")
      lv |> element("a", "利用プラン") |> render_click()

      assert lv |> has_element?("#current_subscription_plan", "誰でもダイレクト採用")
    end
  end
end
