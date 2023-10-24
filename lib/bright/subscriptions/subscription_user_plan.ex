defmodule Bright.Subscriptions.SubscriptionUserPlan do
  @moduledoc """
  ユーザーのサブスクリプション契約の履歴を扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "subscription_user_plans" do
    field :subscription_end_datetime, :naive_datetime
    field :subscription_start_datetime, :naive_datetime

    field :subscription_status, Ecto.Enum,
      values: [:free_trial, :subscribing, :subscription_ended]

    field :trial_end_datetime, :naive_datetime
    field :trial_start_datetime, :naive_datetime

    belongs_to :user, Bright.Accounts.User
    belongs_to :subscription_plan, Bright.Subscriptions.SubscriptionPlan

    timestamps()
  end

  @doc false
  def changeset(subscription_user_plan, attrs) do
    subscription_user_plan
    |> cast(attrs, [
      :user_id,
      :subscription_plan_id,
      :subscription_status,
      :subscription_start_datetime,
      :subscription_end_datetime,
      :trial_start_datetime,
      :trial_end_datetime
    ])
    |> validate_required([
      :user_id,
      :subscription_plan_id,
      :subscription_status,
      :subscription_start_datetime
    ])
  end
end
