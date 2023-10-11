defmodule Brignt.Seeds.SubscriptionPlanService do
  @moduledoc """
  開発用のプランサービスSeedデータ
  """

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionPlan
  alias Bright.Subscriptions.SubscriptionUserPlan

  @plan_services [
    %{plan_code: "personal_skill_up_plan", service_code: "skill_up"},
    %{plan_code: "team_up_plan", service_code: "skill_up"},
    %{plan_code: "team_up_plan", service_code: "team_up"},
    %{plan_code: "hr_plan", service_code: "skill_up"},
    %{plan_code: "hr_plan", service_code: "team_up"},
    %{plan_code: "hr_plan", service_code: "hr_basic"},
    %{plan_code: "hr_plan", service_code: "hr_recruitment "},
    %{plan_code: "hr_plan", service_code: "hr_training"}
  ]

  def insert() do
    @plan_services
    |> Enum.each(fn plan_service ->
      with %SubscriptionPlan{} = plan <-
             Subscriptions.get_plan_by_plan_code(plan_service.plan_code) do
        Subscriptions.create_subscription_plan_service(%{
          subscription_plan_id: plan.id,
          service_code: plan_service.service_code
        })
      end
    end)
  end

  def delete() do
    @plan_services
    |> Enum.uniq_by(fn plan_service -> plan_service.service_code end)
    |> Enum.each(fn plan_service ->
      Subscriptions.delete_subscription_plan_service_by_service_code(plan_service.service_code)
    end)
  end
end
