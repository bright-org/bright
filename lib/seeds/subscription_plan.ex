defmodule Bright.Seeds.SubscriptionPlan do
  @moduledoc """
  開発用のプランSeedデータ
  """

  alias Bright.Subscriptions

  @plans [
    %{
      plan_code: "together",
      name_jp: "みんなでワイワイ",
      create_teams_limit: 3,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 7,
      free_trial_priority: 2,
      authorization_priority: 100
    },
    %{
      plan_code: "together_limit_extended",
      name_jp: "みんなでワイワイ 拡張プラン",
      create_teams_limit: 12,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 28,
      free_trial_priority: nil,
      authorization_priority: 110
    },
    %{
      plan_code: "team_up_plan",
      name_jp: "チームの価値を発掘",
      create_teams_limit: 6,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 14,
      free_trial_priority: 3,
      authorization_priority: 200
    },
    %{
      plan_code: "team_up_plan_limit_extended",
      name_jp: "チームの価値を発掘 拡張プラン",
      create_teams_limit: 24,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 64,
      free_trial_priority: nil,
      authorization_priority: 210
    },
    %{
      plan_code: "hr_plan",
      name_jp: "誰でもダイレクト採用",
      create_teams_limit: 12,
      create_enable_hr_functions_teams_limit: 2,
      team_members_limit: 28,
      free_trial_priority: 4,
      authorization_priority: 300
    },
    %{
      plan_code: "hr_plan_limit_exended",
      name_jp: "誰でもダイレクト採用 拡張プラン",
      create_teams_limit: 48,
      create_enable_hr_functions_teams_limit: 8,
      team_members_limit: 112,
      free_trial_priority: nil,
      authorization_priority: 310
    }
  ]

  def insert() do
    @plans
    |> Enum.map(fn plan ->
      {:ok, subscription_plan} = Subscriptions.create_subscription_plan(plan)
      subscription_plan
    end)
  end

  def delete() do
    # 本シードで設定されているplan_codeのみ対象としている
    # また外部キー制約のため各関連テーブルデータを先に削除
    plan_codes = Enum.map(@plans, & &1.plan_code)

    plans =
      Subscriptions.list_subscription_plans()
      |> Enum.filter(&(&1.plan_code in plan_codes))

    plan_ids = Enum.map(plans, & &1.id)

    # ユーザーのサブスクリプション状況用データ
    user_plans =
      Subscriptions.list_subscription_user_plans()
      |> Enum.filter(&(&1.subscription_plan_id in plan_ids))

    Enum.each(user_plans, &Subscriptions.delete_subscription_user_plan/1)

    # プランサービス
    plan_services =
      Subscriptions.list_subscription_plan_services()
      |> Enum.filter(&(&1.subscription_plan_id in plan_ids))

    Enum.each(plan_services, &Subscriptions.delete_subscription_plan_service/1)

    # プラン
    Enum.each(plans, &Subscriptions.delete_subscription_plan/1)
  end
end
