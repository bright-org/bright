defmodule BrightWeb.Admin.StripePriceLive.Show do
  use BrightWeb, :live_view

  alias Bright.Stripe

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:stripe_price, Stripe.get_stripe_price!(id))}
  end

  defp page_title(:show), do: "Show Stripe price"
  defp page_title(:edit), do: "Edit Stripe price"
end
