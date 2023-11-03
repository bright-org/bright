defmodule Brignt.Seeds.SubscriptionPlan do
  @moduledoc """
  開発用のプランSeedデータ
  """

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionPlan

  @plans [
    %{
      plan_code: "personal_skill_up_plan",
      name_jp: "個人スキルアップ",
      create_teams_limit: 1,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 5,
      free_trial_priority: 2
    },
    %{
      plan_code: "team_up_plan",
      name_jp: "チームアップ",
      create_teams_limit: 5,
      create_enable_hr_functions_teams_limit: 0,
      team_members_limit: 15,
      free_trial_priority: 3
    },
    %{
      plan_code: "hr_plan",
      name_jp: "採用・人材育成",
      create_teams_limit: 5,
      create_enable_hr_functions_teams_limit: 2,
      team_members_limit: 15,
      free_trial_priority: 4
    }
  ]

  def insert() do
    @plans
    |> Enum.each(fn plan ->
      Subscriptions.create_subscription_plan(plan)
    end)
  end

  def delete() do
    @plans
    |> Enum.each(fn plan ->
      with %SubscriptionPlan{} = plan <- Subscriptions.get_plan_by_plan_code(plan.plan_code) do
        Subscriptions.delete_subscription_plan(plan)
      end
    end)
  end
end
