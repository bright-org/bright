defmodule Bright.SubscriptionsTest do
  use Bright.DataCase

  alias Bright.Subscriptions

  import Bright.Factory

  describe "get_create_teams_limit/1" do
    test "returns 1 when plan is nil" do
      assert 1 == Subscriptions.get_create_teams_limit(nil)
    end

    test "returns subscription_plans value" do
      plan = insert(:subscription_plans)
      assert plan.create_teams_limit == Subscriptions.get_create_teams_limit(plan)
    end
  end

  describe "get_team_members_limit/1" do
    test "returns 5 when plan is nil" do
      assert 5 == Subscriptions.get_team_members_limit(nil)
    end

    test "returns subscription_plans value" do
      plan = insert(:subscription_plans)
      assert plan.team_members_limit == Subscriptions.get_team_members_limit(plan)
    end
  end

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
      assert result.trial_start_datetime != nil
      assert result.trial_start_datetime <= NaiveDateTime.utc_now()
      assert result.trial_end_datetime == nil
      assert result.subscription_start_datetime == nil
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
      assert result.subscription_start_datetime != nil
      assert result.subscription_start_datetime <= NaiveDateTime.utc_now()
      assert result.subscription_end_datetime == nil
    end
  end

  describe "get_user_subscription_user_plan/2" do
    test "returns nil when no enabled subscription plans" do
      subscription_plan = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan)

      # トライアル完了済のプランは無視される
      subscription_user_plan_free_trial_end(user, subscription_plan)

      result = Subscriptions.get_user_subscription_user_plan(user.id)
      assert result == nil
    end

    test "returns plan with given user" do
      subscription_plan = insert(:subscription_plans)
      user = insert(:user)
      user_2 = insert(:user)

      subscription_user_plan_free_trial(user, subscription_plan)

      assert Subscriptions.get_user_subscription_user_plan(user.id)
      refute Subscriptions.get_user_subscription_user_plan(user_2.id)
    end

    test "returns highest authorization plan" do
      user = insert(:user)

      # 契約中のプランが返る
      subscription_plan_1 = insert(:subscription_plans, authorization_priority: 1)
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan_1)

      result = Subscriptions.get_user_subscription_user_plan(user.id)
      assert result.subscription_plan.id == subscription_plan_1.id

      # より上位のトライアル中プランが返る
      subscription_plan_2 = insert(:subscription_plans, authorization_priority: 2)
      subscription_user_plan_free_trial(user, subscription_plan_2)

      result = Subscriptions.get_user_subscription_user_plan(user.id)
      assert result.subscription_plan.id == subscription_plan_2.id

      # 過去にトライアル完了済みの上位プランは無視される
      subscription_plan_3 = insert(:subscription_plans, authorization_priority: 3)
      subscription_user_plan_free_trial_end(user, subscription_plan_3)

      result = Subscriptions.get_user_subscription_user_plan(user.id)
      assert result.subscription_plan.id == subscription_plan_2.id

      # 過去に契約完了済みの上位プランは無視される
      subscription_plan_4 = insert(:subscription_plans, authorization_priority: 3)
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan_4)

      result = Subscriptions.get_user_subscription_user_plan(user.id)
      assert result.subscription_plan.id == subscription_plan_2.id
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

    test "not returns free_trial plan" do
      subscription_plan1 = insert(:subscription_plans)
      subscription_plan2 = insert(:subscription_plans)
      user = insert(:user)

      # 契約完了済のプランは無視される
      subscription_user_plan_subscription_end_with_free_trial(user, subscription_plan2)

      # フリートライアル中のプランは無視される
      subscription_user_plan_free_trial(user, subscription_plan1)

      result = Subscriptions.get_users_subscription_status(user.id, NaiveDateTime.utc_now())
      assert result == nil
    end

    test "get high authorization_priority user_plan if user has two plans" do
      # 契約中で２プランがある場合に、より上位のプランを返す確認
      # 基本的に契約中が2プランある状態は発生しない
      subscription_plan1 = insert(:subscription_plans, authorization_priority: 1)
      subscription_plan2 = insert(:subscription_plans, authorization_priority: 2)
      user = insert(:user)

      # 契約中のプラン
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan1)
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan2)

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
      current_attrs = %{
        create_teams_limit: 2,
        create_enable_hr_functions_teams_limit: 2,
        team_members_limit: 10
      }

      # 下記の現プランと比較して"target_service_code"がついているプランを探す
      current_plan = insert(:subscription_plans, current_attrs)

      # 返す対象のプラン
      expected_attrs = Map.put(current_attrs, :free_trial_priority, 1)

      subscription_plan =
        insert(:subscription_plans, expected_attrs)
        |> plan_with_plan_service_by_service_code("target_service_code")

      # チーム数制限が小さい
      _subscription_plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :create_teams_limit, &(&1 - 1)))
        |> plan_with_plan_service_by_service_code("target_service_code")

      # hrチーム数制限が小さい
      _subscription_plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :create_enable_hr_functions_teams_limit, &(&1 - 1))
        )
        |> plan_with_plan_service_by_service_code("target_service_code")

      # メンバー数制限が小さい
      _subscription_plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :team_members_limit, &(&1 - 1)))
        |> plan_with_plan_service_by_service_code("target_service_code")

      # priorityが大きい
      _subscription_plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :free_trial_priority, &(&1 + 1)))
        |> plan_with_plan_service_by_service_code("target_service_code")

      # サービスコードが異なるプランは採用されない
      _subscription_plan =
        insert(:subscription_plans, expected_attrs)
        |> plan_with_plan_service_by_service_code("non_target_service_code")

      result =
        Subscriptions.get_most_priority_free_trial_subscription_plan_by_service(
          "target_service_code",
          current_plan
        )

      assert result.id == subscription_plan.id
    end
  end

  describe "get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit" do
    test "returns best plan" do
      limit_order = 2
      current_plan = nil

      # 上限を満たさない
      _plan_1 =
        insert(:subscription_plans, %{
          create_enable_hr_functions_teams_limit: 1,
          free_trial_priority: 1
        })

      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす
      plan_2 =
        insert(:subscription_plans, %{
          create_enable_hr_functions_teams_limit: 2,
          free_trial_priority: 3
        })

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす / priorityをより優先的に満たす
      plan_3 =
        insert(:subscription_plans, %{
          create_enable_hr_functions_teams_limit: 2,
          free_trial_priority: 2
        })

      assert plan_3 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
                 limit_order,
                 current_plan
               )
    end

    test "returns best plan with current_plan" do
      current_attrs = %{
        create_teams_limit: 5,
        create_enable_hr_functions_teams_limit: 2,
        team_members_limit: 5,
        authorization_priority: 2
      }

      limit_order = 3

      # 下記の現プランと比較して、create_enable_hr_functions_teams_limit: limit_orderを満たすプランを探す
      current_plan = insert(:subscription_plans, current_attrs)

      # 返す対象のプランが満たす属性
      expected_attrs =
        Map.put(current_attrs, :create_enable_hr_functions_teams_limit, limit_order)

      # 同じプラン（満たさない）
      _plan = insert(:subscription_plans, current_attrs)

      # グレードを満たさない
      _plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :authorization_priority, &(&1 - 1))
        )

      # 各制限数を満たさない
      _plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :create_teams_limit, &(&1 - 1)))

      _plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :team_members_limit, &(&1 - 1)))

      # フリートライアル対象外
      _plan = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, nil))

      # ここまでのプランは全て満たさないので何も返さない
      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
                 limit_order,
                 current_plan
               )

      # 条件を満たす / 最も優先されるものを返す
      _plan_1 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 3))
      plan_2 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 1))
      _plan_3 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 2))

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_hr_support_teams_limit(
                 limit_order,
                 current_plan
               )
    end
  end

  describe "get_most_priority_free_trial_subscription_plan_by_teams_limit" do
    test "returns best plan" do
      limit_order = 2
      current_plan = nil

      # 上限を満たさない / priorityを満たす
      _plan_1 = insert(:subscription_plans, %{create_teams_limit: 1, free_trial_priority: 1})

      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす / priorityを満たす
      plan_2 = insert(:subscription_plans, %{create_teams_limit: 2, free_trial_priority: 3})

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす / priorityをより優先的に満たす
      plan_3 = insert(:subscription_plans, %{create_teams_limit: 2, free_trial_priority: 2})

      assert plan_3 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
                 limit_order,
                 current_plan
               )
    end

    test "returns best plan with current_plan" do
      current_attrs = %{
        create_teams_limit: 5,
        create_enable_hr_functions_teams_limit: 2,
        team_members_limit: 5,
        authorization_priority: 2
      }

      limit_order = 6

      # 下記の現プランと比較して、create_teams_limit: limit_orderを満たすプランを探す
      current_plan = insert(:subscription_plans, current_attrs)

      # 返す対象のプランが満たす属性
      expected_attrs = Map.put(current_attrs, :create_teams_limit, limit_order)

      # 同じプラン（満たさない）
      _plan = insert(:subscription_plans, current_attrs)

      # グレードを満たさない
      _plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :authorization_priority, &(&1 - 1))
        )

      # 各制限数を満たさない
      _plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :create_enable_hr_functions_teams_limit, &(&1 - 1))
        )

      _plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :team_members_limit, &(&1 - 1)))

      # フリートライアル対象外
      _plan = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, nil))

      # ここまでのプランは全て満たさないので何も返さない
      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
                 limit_order,
                 current_plan
               )

      # 条件を満たす / 最も優先されるものを返す
      _plan_1 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 3))
      plan_2 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 1))
      _plan_3 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 2))

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_teams_limit(
                 limit_order,
                 current_plan
               )
    end
  end

  describe "get_most_priority_free_trial_subscription_plan_by_members_limit" do
    test "returns best plan" do
      limit_order = 6
      current_plan = nil

      # 上限を満たさない / priorityを満たす
      _plan_1 = insert(:subscription_plans, %{team_members_limit: 5, free_trial_priority: 1})

      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす / priorityを満たす
      plan_2 = insert(:subscription_plans, %{team_members_limit: 6, free_trial_priority: 3})

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
                 limit_order,
                 current_plan
               )

      # 上限を満たす / priorityをより優先的に満たす
      plan_3 = insert(:subscription_plans, %{team_members_limit: 6, free_trial_priority: 2})

      assert plan_3 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
                 limit_order,
                 current_plan
               )
    end

    test "returns best plan with current_plan" do
      current_attrs = %{
        create_teams_limit: 5,
        create_enable_hr_functions_teams_limit: 2,
        team_members_limit: 10,
        authorization_priority: 2
      }

      limit_order = 11

      # 下記の現プランと比較して、team_members_limit: limit_orderを満たすプランを探す
      current_plan = insert(:subscription_plans, current_attrs)

      # 返す対象のプランが満たす属性
      expected_attrs = Map.put(current_attrs, :team_members_limit, limit_order)

      # 同じプラン（満たさない）
      _plan = insert(:subscription_plans, current_attrs)

      # グレードを満たさない
      _plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :authorization_priority, &(&1 - 1))
        )

      # 各制限数を満たさない
      _plan =
        insert(:subscription_plans, Map.update!(expected_attrs, :create_teams_limit, &(&1 - 1)))

      _plan =
        insert(
          :subscription_plans,
          Map.update!(expected_attrs, :create_enable_hr_functions_teams_limit, &(&1 - 1))
        )

      # フリートライアル対象外
      _plan = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, nil))

      # ここまでのプランは全て満たさないので何も返さない
      assert nil ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
                 limit_order,
                 current_plan
               )

      # 条件を満たす / 最も優先されるものを返す
      _plan_1 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 3))
      plan_2 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 1))
      _plan_3 = insert(:subscription_plans, Map.put(expected_attrs, :free_trial_priority, 2))

      assert plan_2 ==
               Subscriptions.get_most_priority_free_trial_subscription_plan_by_members_limit(
                 limit_order,
                 current_plan
               )
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
    setup do
      low_plan =
        insert(:subscription_plans,
          authorization_priority: 1,
          free_trial_priority: 1,
          create_teams_limit: 3,
          create_enable_hr_functions_teams_limit: 0,
          team_members_limit: 6
        )

      mid_plan =
        insert(:subscription_plans,
          authorization_priority: 2,
          free_trial_priority: 2,
          create_teams_limit: 6,
          create_enable_hr_functions_teams_limit: 0,
          team_members_limit: 12
        )
        |> plan_with_plan_services_by_service_codes(~w(srv1))

      high_plan =
        insert(:subscription_plans,
          authorization_priority: 3,
          free_trial_priority: 3,
          create_teams_limit: 9,
          create_enable_hr_functions_teams_limit: 2,
          team_members_limit: 24
        )
        |> plan_with_plan_services_by_service_codes(~w(srv1 srv2))

      user = insert(:user)

      %{user: user, plans: [low_plan, mid_plan, high_plan]}
    end

    test "no plan first trial", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      assert {true, _} = Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, mid_plan.plan_code)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, high_plan.plan_code)
    end

    test "already available, case same trial", %{
      user: user,
      plans: [low_plan | _]
    } do
      # 同一プランでトライアル中
      subscription_user_plan_free_trial(user, low_plan)

      assert {false, :already_available} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "already available, case same subscription", %{
      user: user,
      plans: [low_plan | _]
    } do
      # 同一プランで契約中
      subscription_user_plan_subscribing_without_free_trial(user, low_plan)

      assert {false, :already_available} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "already available, case higher trial", %{
      user: user,
      plans: [low_plan, mid_plan, _high_plan]
    } do
      # 上位プランでトライアル中
      subscription_user_plan_free_trial(user, mid_plan)

      assert {false, :already_available} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "already available, case higher subscription", %{
      user: user,
      plans: [low_plan, mid_plan, _high_plan]
    } do
      # 上位プランで契約中
      subscription_user_plan_subscribing_without_free_trial(user, mid_plan)

      assert {false, :already_available} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "takes ok, case lower subscription", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      # 下位プランを契約中
      subscription_user_plan_subscribing_without_free_trial(user, low_plan)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, mid_plan.plan_code)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, high_plan.plan_code)
    end

    test "takes ok, case lower trial", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      # 下位プランをトライアル中
      subscription_user_plan_free_trial(user, low_plan)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, mid_plan.plan_code)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, high_plan.plan_code)
    end

    test "takes ok, case high condition", %{
      user: user,
      plans: [_low_plan, _mid_plan, high_plan]
    } do
      # 上位プランをトライアル中
      subscription_user_plan_free_trial(user, high_plan)

      # より制限が大きいプランを仮定
      higher_plan =
        insert(:subscription_plans,
          authorization_priority: 3,
          free_trial_priority: 3,
          create_enable_hr_functions_teams_limit: 3
        )
        |> plan_with_plan_services_by_service_codes(~w(srv1 srv2))

      assert {true, _} = Subscriptions.free_trial_available?(user.id, higher_plan.plan_code)
    end

    test "already used once, case same trial", %{
      user: user,
      plans: [low_plan | _]
    } do
      # 同一プランで既にトライアル完了済み
      subscription_user_plan_free_trial_end(user, low_plan)

      assert {false, :already_used_once} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "already used once, case same subscription", %{
      user: user,
      plans: [low_plan | _]
    } do
      # 同一プランで既に契約完了済み
      subscription_user_plan_subscription_end_without_free_trial(user, low_plan)

      assert {false, :already_used_once} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "takes ok, case higher plan used once", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      # 上位プランが以前完了済み（同一ではないので可能）
      subscription_user_plan_subscription_end_without_free_trial(user, mid_plan)
      subscription_user_plan_free_trial_end(user, high_plan)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, low_plan.plan_code)
    end

    test "takes ok, case lower plan used once", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      # 下位プランが以前完了済み（同一ではないので可能）
      subscription_user_plan_subscription_end_without_free_trial(user, mid_plan)
      subscription_user_plan_free_trial_end(user, low_plan)
      assert {true, _} = Subscriptions.free_trial_available?(user.id, high_plan.plan_code)
    end

    test "not for trial", %{
      user: user
    } do
      # トライアル優先度がnilのものは対象外
      other_plan =
        insert(:subscription_plans, authorization_priority: 2, free_trial_priority: nil)

      assert {false, :not_for_trial} =
               Subscriptions.free_trial_available?(user.id, other_plan.plan_code)
    end

    test "not for trial, case current plan is extended", %{
      user: user,
      plans: [low_plan, mid_plan, high_plan]
    } do
      # トライアル優先度がnil契約中は、いずれも対象外とする
      other_plan =
        insert(:subscription_plans, authorization_priority: 2, free_trial_priority: nil)

      subscription_user_plan_subscribing_without_free_trial(user, other_plan)

      assert {false, :not_for_trial} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)

      assert {false, :not_for_trial} =
               Subscriptions.free_trial_available?(user.id, mid_plan.plan_code)

      assert {false, :not_for_trial} =
               Subscriptions.free_trial_available?(user.id, high_plan.plan_code)
    end

    test "scopes given user", %{
      user: user,
      plans: [low_plan | _]
    } do
      # 引数のuserが対象になっている確認
      subscription_user_plan_subscription_end_without_free_trial(user, low_plan)

      assert {false, :already_used_once} =
               Subscriptions.free_trial_available?(user.id, low_plan.plan_code)

      user_2 = insert(:user)
      assert {true, _} = Subscriptions.free_trial_available?(user_2.id, low_plan.plan_code)
    end
  end
end
