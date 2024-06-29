defmodule BrightWeb.UserSettingsLive.CurrentSubscriptionPlanComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionUserPlan

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="flex flex-col mt-8">
        <div id="current_subscription_plan" class="flex flex-col lg:flex-row lg:flex-wrap text-left">
          <div class="w-full">
            <label class="flex items-center py-4">
              <span class="w-32">利用プラン</span>
              <span class="w-full"><%= @plan %></span>
            </label>
          </div>
        </div>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    subscription_user_plan = Subscriptions.get_user_subscription_user_plan(assigns.user.id)

    current_datetime = NaiveDateTime.utc_now()

    plan =
      case subscription_user_plan do
        %SubscriptionUserPlan{
          subscription_status: :free_trial,
          trial_start_datetime: trial_start,
          trial_end_datetime: nil,
          subscription_plan: %{name_jp: name_jp}
        }
        when current_datetime >= trial_start ->
          "#{name_jp}（無料トライアル中）"

        %SubscriptionUserPlan{
          subscription_status: :free_trial,
          subscription_plan: %{name_jp: name_jp},
          trial_start_datetime: trial_start_datetime,
          trial_end_datetime: trial_end_datetime
        }
        when current_datetime >= trial_start_datetime and current_datetime <= trial_end_datetime ->
          "#{name_jp}（無料トライアル中）"

        %SubscriptionUserPlan{
          subscription_status: :subscribing,
          subscription_plan: %{name_jp: name_jp}
        } ->
          name_jp

        _ ->
          "なし"
      end

    socket =
      socket
      |> assign(:plan, plan)

    {:ok, socket}
  end
end
