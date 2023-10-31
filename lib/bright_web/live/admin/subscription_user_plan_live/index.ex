defmodule BrightWeb.Admin.SubscriptionUserPlanLive.Index do
  use BrightWeb, :live_view

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionUserPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(
       socket,
       :subscription_user_plans,
       Subscriptions.list_subscription_user_plans_with_plan()
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subscription user plan")
    |> assign(:subscription_user_plan, Subscriptions.get_subscription_user_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscription user plan")
    |> assign(:subscription_user_plan, %SubscriptionUserPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscription user plans")
    |> assign(:subscription_user_plan, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.SubscriptionUserPlanLive.FormComponent,
         {:saved, subscription_user_plan}},
        socket
      ) do
    plan = Subscriptions.get_subscription_user_plan_with_plan!(subscription_user_plan.id)
    {:noreply, stream_insert(socket, :subscription_user_plans, plan)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscription_user_plan = Subscriptions.get_subscription_user_plan!(id)
    {:ok, _} = Subscriptions.delete_subscription_user_plan(subscription_user_plan)

    {:noreply, stream_delete(socket, :subscription_user_plans, subscription_user_plan)}
  end
end
