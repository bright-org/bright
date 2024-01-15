defmodule Bright.SubscriptionsTest do
  use Bright.DataCase

  alias Bright.Subscriptions

  import Bright.Factory

  describe "get_plan_by_plan_code/1" do
    test "get_plan_by_plan_code/1 rerutn one subscription_plans" do
      _subscription_plan1 = insert(:subscription_plans)
      subscription_plan2 = insert(:subscription_plans)
      _subscription_plan3 = insert(:subscription_plans)

      result1 = Subscriptions.get_plan_by_plan_code(subscription_plan2.plan_code)
      assert result1.name_jp == subscription_plan2.name_jp
    end

    test "get_plan_by_plan_code/1 rerutn no subscription_plans" do
      _subscription_plan1 = insert(:subscription_plans)

      hogehoge_plan = Subscriptions.get_plan_by_plan_code("hogehoge")
      assert is_nil(hogehoge_plan)
    end
  end

  describe "delete_subscription_plan_service_by_service_code/1" do
    test "delete subscription_plan_service" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      subscription_plan_service = List.first(subscription_plan1.subscription_plan_services)

      _result =
        Subscriptions.get_subscription_plan_with_enable_services_by_plan_code(
          subscription_plan1.plan_code
        )

      result =
        Subscriptions.get_subscription_plan_with_enable_services_by_plan_code(
          subscription_plan1.plan_code
        )

      assert true ==
               result.subscription_plan_services
               |> Enum.any?()

      Subscriptions.delete_subscription_plan_service_by_service_code(
        subscription_plan_service.service_code
      )

      result =
        Subscriptions.get_subscription_plan_with_enable_services_by_plan_code(
          subscription_plan1.plan_code
        )

      assert false ==
               result.subscription_plan_services
               |> Enum.any?()
    end
  end

  describe "start_free_trial/2" do
    test "sucsecc start free trial" do
      subscription_plan1 = insert(:subscription_plans)
      user = insert(:user)
      form = %{company_name: "test company", pic_name: "test cto", phone_number: "01203333906"}
      assert {:ok, result} = Subscriptions.start_free_trial(user.id, subscription_plan1.id, form)

      assert result.user_id == user.id
      assert result.subscription_plan_id == subscription_plan1.id
      assert result.subscription_status == :free_trial
      assert result.trial_start_datetime <= NaiveDateTime.utc_now()
      assert result.trial_end_datetime == nil
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
      assert result.company_name == "test company"
      assert result.pic_name == "test cto"
      assert result.phone_number == "01203333906"
    end
  end

  describe "start_subscription/2" do
    test "sucsecc start subscription" do
      subscription_plan1 = insert(:subscription_plans)
      user = insert(:user)

      assert {:ok, result} = Subscriptions.start_subscription(user.id, subscription_plan1.id)

      assert result.user_id == user.id
      assert result.subscription_plan_id == subscription_plan1.id
      assert result.subscription_status == :subscribing
      assert result.trial_start_datetime == nil
      assert result.trial_end_datetime == nil
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
    end
  end

  describe "get_users_subscription_status/2" do
    test "no enable subscription plan" do
      subscription_plan1 = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan1)

      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

      # 契約中のプランが存在しない場合nilを返す
      assert result == nil
    end

    test "one get subscripting with free_trial plan" do
      subscription_plan1 = insert(:subscription_plans)
      subscription_plan2 = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan2)

      # 契約中のプランが取得される
      subscription_user_plan_subscribing_with_free_trial(user, subscription_plan1)

      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

      assert result.user_id == user.id
      assert result.subscription_plan_id == subscription_plan1.id
      assert result.subscription_status == :subscribing
      assert result.trial_start_datetime <= NaiveDateTime.utc_now()
      assert result.trial_end_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
    end

    test "get subscripting without free_trial plan" do
      subscription_plan1 = insert(:subscription_plans)
      subscription_plan2 = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan2)

      # 契約中のプランが取得される
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)

      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

      assert result.user_id == user.id
      assert result.subscription_plan_id == subscription_plan1.id
      assert result.subscription_status == :subscribing
      assert result.trial_start_datetime == nil
      assert result.trial_end_datetime == nil
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
    end

    test "one enable on free_trial plan" do
      subscription_plan1 = insert(:subscription_plans)
      subscription_plan2 = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan2)

      # 契約中(フリートライアル中)のプランが取得される
      subscription_user_plan_free_trial(user, subscription_plan1)

      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())

      assert result.user_id == user.id
      assert result.subscription_plan_id == subscription_plan1.id
      assert result.subscription_status == :free_trial
      assert result.trial_start_datetime <= NaiveDateTime.utc_now()
      assert result.trial_end_datetime == nil
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
    end

    test "get high authorization_priority user_plan if user has two plans" do
      # 契約中およびフリートライアル中で２プランがある場合に、より上位のプランを返す確認
      subscription_plan1 = insert(:subscription_plans, authorization_priority: 1)
      subscription_plan2 = insert(:subscription_plans, authorization_priority: 2)
      user = insert(:user)

      # 契約中のプラン
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)

      # 契約中(フリートライアル中)のプラン
      subscription_user_plan_free_trial(user, subscription_plan2)

      # authorization_priorityに従って取得される
      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())
      assert result.subscription_plan_id == subscription_plan2.id
    end
  end

  describe "service_enabled?/2" do
    # サービス利用判定のパターン
    test "true case. subscribing plan and available service" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      user = insert(:user)
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)

      service_code = List.first(subscription_plan1.subscription_plan_services).service_code

      assert true == Subscriptions.service_enabled?(user.id, service_code)
    end

    test "true case. free_trial plan and available service" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      user = insert(:user)
      subscription_user_plan_free_trial(user, subscription_plan1)

      service_code = List.first(subscription_plan1.subscription_plan_services).service_code

      assert true == Subscriptions.service_enabled?(user.id, service_code)
    end

    test "false case. subscribing plan. but disable that service" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      user = insert(:user)
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)

      service_code = List.first(subscription_plan1.subscription_plan_services).service_code

      # プランに紐づけられた内容とサービスコードが一致しない場合はfalse
      assert false == Subscriptions.service_enabled?(user.id, service_code <> "1")
    end

    test "false case. subscription_end plan" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      service_code = List.first(subscription_plan1.subscription_plan_services).service_code

      user = insert(:user)

      # あえて完了済のサブスク契約を作成
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan1)

      # 契約完了の場合はサービスコードが一致していても無効
      assert false == Subscriptions.service_enabled?(user.id, service_code)
    end

    test "false case. not subscribed plan" do
      subscription_plan1 =
        insert(:subscription_plans)
        |> plan_with_plan_service()
        |> Repo.preload(:subscription_plan_services)

      service_code = List.first(subscription_plan1.subscription_plan_services).service_code
      user = insert(:user)
      other_user = insert(:user)

      # 本人以外で契約
      subscription_user_plan_subscription_end_with_free_trial(other_user, subscription_plan1)

      # 契約完了の場合はサービスコードが一致していても無効
      assert false == Subscriptions.service_enabled?(user.id, service_code)
    end
  end

  describe "get_most_priority_free_trial_subscription_plan_by_service/2" do
    test "returns best plan" do
      # priorityが低い(数字が大きい)プランは採用されない)
      _subscription_plan1 =
        insert(:subscription_plans, %{free_trial_priority: 3})
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # 対象のサービスコードが有効なプランの内、priaorityが最も小さいものが優先される
      subscription_plan2 =
        insert(:subscription_plans, %{free_trial_priority: 2})
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # サービスコードが異なるプランは採用されない
      _subscription_plan3 =
        insert(:subscription_plans, %{free_trial_priority: 1})
        |> plan_with_plan_service_by_service_code("non_target_service_code")
        |> Repo.preload(:subscription_plan_services)

      result =
        Subscriptions.get_most_priority_free_trial_subscription_plan_by_service(
          "target_service_code"
        )

      assert result.id == subscription_plan2.id
    end

    test "returns best plan with current_plan" do
      current_plan = insert(:subscription_plans, %{create_teams_limit: 2, team_members_limit: 10})

      # チーム数制限が小さい
      _subscription_plan1 =
        insert(:subscription_plans, %{create_teams_limit: 1, team_members_limit: 11})
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # メンバー数制限が小さい
      _subscription_plan2 =
        insert(:subscription_plans, %{create_teams_limit: 2, team_members_limit: 9})
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # priorityが大きい
      _subscription_plan3 =
        insert(:subscription_plans, %{
          create_teams_limit: 2,
          team_members_limit: 10,
          free_trial_priority: 3
        })
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # priorityが小さい
      subscription_plan =
        insert(:subscription_plans, %{
          create_teams_limit: 2,
          team_members_limit: 10,
          free_trial_priority: 2
        })
        |> plan_with_plan_service_by_service_code("target_service_code")
        |> Repo.preload(:subscription_plan_services)

      # サービスコードが異なるプランは採用されない
      _subscription_plan4 =
        insert(:subscription_plans, %{
          create_teams_limit: 2,
          team_members_limit: 10,
          free_trial_priority: 1
        })
        |> plan_with_plan_service_by_service_code("non_target_service_code")
        |> Repo.preload(:subscription_plan_services)

      result =
        Subscriptions.get_most_priority_free_trial_subscription_plan_by_service(
          "target_service_code",
          current_plan
        )

      assert result.id == subscription_plan.id
    end
  end

  describe "get_users_trialed_plans/1" do
    test "no trial plan. only direct subscription withou free trial" do
      subscription_plan1 = insert(:subscription_plans)

      user = insert(:user)
      other_user = insert(:user)

      # フリートライアルを実施していない契約は無視される
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)
      # 他のユーザーの契約は無視される
      subscription_user_plan_subscribing_with_free_trial(other_user, subscription_plan1)

      result = Subscriptions.get_users_trialed_plans(user.id)
      assert result == []
    end

    test "2 free trialed plan. subscription_end with free trial and subscribing with free trial" do
      subscription_plan1 = insert(:subscription_plans)

      subscription_plan2 = insert(:subscription_plans)

      subscription_plan3 = insert(:subscription_plans)

      user = insert(:user)

      # フリートライアルを実施しいる契約はステータスにかかわらず取得対象
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan1)
      # フリートライアルを実施していない契約は無視される
      subscription_user_plan_subscription_end_without_free_trial(user, subscription_plan2)

      # フリートライアルを実施しいる契約はステータスにかかわらず取得対象
      subscription_user_plan_subscribing_with_free_trial(user, subscription_plan3)

      result = Subscriptions.get_users_trialed_plans(user.id)
      assert length(result) == 2

      assert result
             |> Enum.any?(fn subscription_plan_user ->
               subscription_plan_user.subscription_plan_id == subscription_plan1.id
             end)

      assert result
             |> Enum.any?(fn subscription_plan_user ->
               subscription_plan_user.subscription_plan_id == subscription_plan3.id
             end)
    end
  end

  describe "free_trial_available?/1" do
    test "no trial plan" do
      subscription_plan1 = insert(:subscription_plans)

      user = insert(:user)
      other_user = insert(:user)

      # フリートライアルを実施していない契約は無視される
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)
      # 他のユーザーの契約は無視される
      subscription_user_plan_subscribing_with_free_trial(other_user, subscription_plan1)

      assert true == Subscriptions.free_trial_available?(user.id, subscription_plan1.plan_code)
    end

    test "exist subscription end with free trial plan" do
      subscription_plan1 = insert(:subscription_plans)

      user = insert(:user)

      # フリートライアルを実施しいる契約はステータスにかかわらずトライアル済と判断
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan1)

      assert false == Subscriptions.free_trial_available?(user.id, subscription_plan1.plan_code)
    end

    test "exist subscribing with free trial plan" do
      subscription_plan1 = insert(:subscription_plans)

      user = insert(:user)

      # フリートライアルを実施しいる契約はステータスにかかわらずトライアル済と判断
      subscription_user_plan_subscribing_with_free_trial(user, subscription_plan1)

      assert false == Subscriptions.free_trial_available?(user.id, subscription_plan1.plan_code)
    end

    test "exist on free trial plan" do
      subscription_plan1 = insert(:subscription_plans)

      user = insert(:user)

      # フリートライアルを実施しいる契約はステータスにかかわらずトライアル済と判断
      subscription_user_plan_free_trial(user, subscription_plan1)

      assert false == Subscriptions.free_trial_available?(user.id, subscription_plan1.plan_code)
    end
  end
end
