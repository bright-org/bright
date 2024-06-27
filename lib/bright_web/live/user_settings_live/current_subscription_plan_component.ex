defmodule BrightWeb.UserSettingsLive.CurrentSubscriptionPlanComponent do
  use BrightWeb, :live_component

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Subscriptions.SubscriptionUserPlan

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="flex flex-col mt-8">
      <div class="flex flex-col lg:flex-row lg:flex-wrap text-left">
          <div class="w-full lg:w-1/2">
            <label class="flex items-center py-4">
              <span class="w-32">利用プラン</span>
              <span class="w-64"><%= @plan %></span>
            </label>
          </div>
        </div>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    subscription_user_plan =
      from(sup in SubscriptionUserPlan,
        where:
          sup.user_id == ^assigns.user.id and
            sup.subscription_status in [:free_trial, :subscribing],
        preload: :subscription_plan
      )
      |> Repo.one()

    plan =
      case subscription_user_plan do
        nil ->
          "利用プランなし"

        %SubscriptionUserPlan{
          subscription_status: :free_trial,
          subscription_plan: %{name_jp: name_jp}
        } ->
          "#{name_jp}（無料トライアル中）"

        %SubscriptionUserPlan{subscription_plan: %{name_jp: name_jp}} ->
          name_jp
      end

    socket =
      socket
      |> assign(:plan, plan)

    {:ok, socket}
  end
end
