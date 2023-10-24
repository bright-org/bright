defmodule BrightWeb.Admin.SubscriptionPlanServiceLive.Index do
  use BrightWeb, :live_view

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionPlanService

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     stream(socket, :subscription_plan_services, Subscriptions.list_subscription_plan_services())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Subscription plan service")
    |> assign(:subscription_plan_service, Subscriptions.get_subscription_plan_service!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Subscription plan service")
    |> assign(:subscription_plan_service, %SubscriptionPlanService{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Subscription plan services")
    |> assign(:subscription_plan_service, nil)
  end

  @impl true
  def handle_info(
        {BrightWeb.Admin.SubscriptionPlanServiceLive.FormComponent,
         {:saved, subscription_plan_service}},
        socket
      ) do
    {:noreply, stream_insert(socket, :subscription_plan_services, subscription_plan_service)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    subscription_plan_service = Subscriptions.get_subscription_plan_service!(id)
    {:ok, _} = Subscriptions.delete_subscription_plan_service(subscription_plan_service)

    {:noreply, stream_delete(socket, :subscription_plan_services, subscription_plan_service)}
  end
end
