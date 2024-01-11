defmodule BrightWeb.CreateFreeTrialTest do
  use BrightWeb.ConnCase

  alias Bright.Subscriptions
  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "free_trial from mypage" do
    setup [:register_and_log_in_user]

    setup do
      plan =
        insert(:subscription_plans,
          plan_code: "hr_plan",
          name_jp: "採用・人材育成プラン",
          free_trial_priority: 20,
          authorization_priority: 20
        )

      %{plan: plan}
    end

    test "view create_modal", %{conn: conn} do
      {:ok, index_live, html} = live(conn, ~p"/free_trial?plan=hr_plan")

      assert html =~ "採用・人材育成プラン"
      assert index_live |> has_element?("button", "開始する")
    end

    test "view create_modal default hr_plan", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/free_trial")

      assert html =~ "採用・人材育成プラン"
    end

    test "view create_modal with no exist plan params", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/free_trial?plan=hoge")

      assert html =~ "採用・人材育成プラン"
    end

    test "view create_modal other plan", %{conn: conn} do
      insert(:subscription_plans, plan_code: "team_up_plan", name_jp: "チームアッププラン")
      {:ok, _index_live, html} = live(conn, ~p"/free_trial?plan=team_up_plan")

      assert html =~ "チームアッププラン"
    end

    test "view create_modal lower priority plan when free_trialing hr_plan ", %{
      conn: conn,
      user: user,
      plan: plan
    } do
      insert(:subscription_user_plan_free_trial, user: user, subscription_plan: plan)

      insert(:subscription_plans,
        plan_code: "team_up_plan",
        name_jp: "チームアッププラン",
        free_trial_priority: 1
      )

      {:ok, index_live, html} = live(conn, ~p"/free_trial?plan=team_up_plan")
      assert html =~ "採用・人材育成プラン"
      assert index_live |> has_element?("p", "このプランはすでに選択済みです")
    end

    test "view create_modal lower priority plan when subscribing hr_plan ", %{
      conn: conn,
      user: user,
      plan: plan
    } do
      insert(:subscription_user_plan_subscribing_without_free_trial,
        user: user,
        subscription_plan: plan,
        subscription_status: :subscribing,
        subscription_end_datetime: NaiveDateTime.utc_now()
      )

      insert(:subscription_plans,
        plan_code: "team_up_plan",
        name_jp: "チームアッププラン",
        free_trial_priority: 1
      )

      {:ok, index_live, html} = live(conn, ~p"/free_trial?plan=team_up_plan")
      assert html =~ "採用・人材育成プラン"
      assert index_live |> has_element?("p", "このプランはすでに選択済みです")
    end

    test "view create_modal free_trialing hr_plan", %{conn: conn, user: user, plan: plan} do
      insert(:subscription_user_plan_free_trial, user: user, subscription_plan: plan)
      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"
      assert index_live |> has_element?("p", "このプランはすでに選択済みです")
    end

    test "view create_modal expired free_trial hr_plan", %{conn: conn, user: user, plan: plan} do
      insert(:subscription_user_plan_free_trial,
        user: user,
        subscription_plan: plan,
        trial_end_datetime: NaiveDateTime.utc_now()
      )

      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"
      assert index_live |> has_element?("p", "このプランの無料トライアル期間は終了しています")
    end

    test "view create_modal expired hr_plan", %{conn: conn, user: user, plan: plan} do
      insert(:subscription_user_plan_subscribing_without_free_trial,
        user: user,
        subscription_plan: plan,
        subscription_status: :subscription_ended,
        subscription_end_datetime: NaiveDateTime.utc_now()
      )

      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"

      assert index_live |> has_element?("p", "このプランの無料トライアル期間は終了しています")
    end

    test "validate empty form submit", %{conn: conn} do
      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"

      assert index_live
             |> element("#free_trial_form")
             |> render_submit() =~ "入力してください"
    end

    test "validate input required", %{conn: conn} do
      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"

      assert index_live
             |> element("#free_trial_form")
             |> render_submit(%{
               free_trial_form: %{
                 company_name: "sample company",
                 phone_number: "00000",
                 email: "hoge@email.com"
               }
             }) =~ "入力してください"
    end

    test "free_trial start", %{conn: conn, user: user} do
      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"

      assert is_nil(Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now()))

      index_live
      |> element("#free_trial_form")
      |> render_submit(%{
        free_trial_form: %{
          company_name: "sample company",
          phone_number: "00000",
          email: "hoge@email.com",
          pic_name: "PM"
        }
      })

      assert_patch(index_live, "/mypage")

      %{subscription_status: :free_trial, subscription_plan: %{plan_code: "hr_plan"}} =
        Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())
    end

    test "free_trialing low_priority_plan", %{conn: conn, user: user} do
      low_plan =
        insert(:subscription_plans,
          plan_code: "team_up_plan",
          name_jp: "チームアッププラン",
          free_trial_priority: 1
        )

      insert(:subscription_user_plan_free_trial, user: user, subscription_plan: low_plan)

      %{subscription_status: :free_trial, subscription_plan: %{plan_code: "team_up_plan"}} =
        Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

      {:ok, index_live, html} = live(conn, ~p"/free_trial")
      assert html =~ "採用・人材育成プラン"

      index_live
      |> element("#free_trial_form")
      |> render_submit(%{
        free_trial_form: %{
          company_name: "sample company",
          phone_number: "00000",
          email: "hoge@email.com",
          pic_name: "PM"
        }
      })

      assert_patch(index_live, "/mypage")

      %{subscription_status: :free_trial, subscription_plan: %{plan_code: "hr_plan"}} =
        Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())
    end
  end
end
