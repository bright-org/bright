defmodule BrightWeb.Admin.StripePriceLive.Index do
  use BrightWeb, :live_view

  alias Bright.Stripe
  alias Bright.Stripe.StripePrice

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :stripe_prices, Stripe.list_stripe_prices())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Stripe price")
    |> assign(:stripe_price, Stripe.get_stripe_price!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Stripe price")
    |> assign(:stripe_price, %StripePrice{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Stripe prices")
    |> assign(:stripe_price, nil)
  end

  @impl true
  def handle_info({BrightWeb.Admin.StripePriceLive.FormComponent, {:saved, stripe_price}}, socket) do
    {:noreply, stream_insert(socket, :stripe_prices, stripe_price)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    stripe_price = Stripe.get_stripe_price!(id)
    {:ok, _} = Stripe.delete_stripe_price(stripe_price)

    {:noreply, stream_delete(socket, :stripe_prices, stripe_price)}
  end
end
