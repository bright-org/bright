defmodule BrightWeb.Admin.SubscriptionPlanLive.Show do
  use BrightWeb, :live_view

  alias Bright.Subscriptions

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:subscription_plan, Subscriptions.get_subscription_plan!(id))}
  end

  defp page_title(:show), do: "Show Subscription plan"
  defp page_title(:edit), do: "Edit Subscription plan"
end
