defmodule Bright.Subscriptions.SubscriptionPlan do
  @moduledoc """
  サブスクリプションプランを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "subscription_plans" do
    field :available_contract_end_datetime, :naive_datetime
    field :create_enable_hr_functions_teams_limit, :integer
    field :create_teams_limit, :integer
    field :free_trial_priority, :integer
    field :authorization_priority, :integer
    field :name_jp, :string
    field :plan_code, :string
    field :team_members_limit, :integer

    has_many :subscription_plan_services, Bright.Subscriptions.SubscriptionPlanService

    timestamps()
  end

  @doc false
  def changeset(subscription_plan, attrs) do
    subscription_plan
    |> cast(attrs, [
      :plan_code,
      :name_jp,
      :create_teams_limit,
      :create_enable_hr_functions_teams_limit,
      :team_members_limit,
      :available_contract_end_datetime,
      :free_trial_priority,
      :authorization_priority
    ])
    |> validate_required([
      :plan_code,
      :name_jp,
      :create_teams_limit,
      :create_enable_hr_functions_teams_limit,
      :team_members_limit,
      :authorization_priority
    ])
  end
end
