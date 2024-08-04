defmodule BrightWeb.StripePriceLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Stripe

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage stripe_price records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="stripe_price-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:stripe_price_id]} type="text" label="Stripe price" />
        <.input field={@form[:stripe_lookup_key]} type="text" label="Stripe lookup key" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Stripe price</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{stripe_price: stripe_price} = assigns, socket) do
    changeset = Stripe.change_stripe_price(stripe_price)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"stripe_price" => stripe_price_params}, socket) do
    changeset =
      socket.assigns.stripe_price
      |> Stripe.change_stripe_price(stripe_price_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"stripe_price" => stripe_price_params}, socket) do
    save_stripe_price(socket, socket.assigns.action, stripe_price_params)
  end

  defp save_stripe_price(socket, :edit, stripe_price_params) do
    case Stripe.update_stripe_price(socket.assigns.stripe_price, stripe_price_params) do
      {:ok, stripe_price} ->
        notify_parent({:saved, stripe_price})

        {:noreply,
         socket
         |> put_flash(:info, "Stripe price updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_stripe_price(socket, :new, stripe_price_params) do
    case Stripe.create_stripe_price(stripe_price_params) do
      {:ok, stripe_price} ->
        notify_parent({:saved, stripe_price})

        {:noreply,
         socket
         |> put_flash(:info, "Stripe price created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
