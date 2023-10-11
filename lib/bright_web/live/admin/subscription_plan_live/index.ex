defmodule BrightWeb.Admin.SubscriptionPlanLive.Index do
  use BrightWeb, :live_view

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionPlan

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :subscription_plans, Subscriptions.list_subscription_plans())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subscription plan")
    |> assign(:subscription_plan, Subscriptions.get_subscription_plan!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscription plan")
    |> assign(:subscription_plan, %SubscriptionPlan{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscription plans")
    |> assign(:subscription_plan, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.SubscriptionPlanLive.FormComponent, {:saved, subscription_plan}},
        socket
      ) do
    {:noreply, stream_insert(socket, :subscription_plans, subscription_plan)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscription_plan = Subscriptions.get_subscription_plan!(id)
    {:ok, _} = Subscriptions.delete_subscription_plan(subscription_plan)

    {:noreply, stream_delete(socket, :subscription_plans, subscription_plan)}
  end
end
