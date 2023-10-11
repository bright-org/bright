defmodule BrightWeb.Admin.SubscriptionPlanServiceLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subscription_plan_service records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subscription_plan_service-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:service_code]} type="text" label="Service code" />
        <.input field={@form[:subscription_plan_id]} type="text" label="Plan" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subscription plan service</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subscription_plan_service: subscription_plan_service} = assigns, socket) do
    changeset = Subscriptions.change_subscription_plan_service(subscription_plan_service)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"subscription_plan_service" => subscription_plan_service_params},
        socket
      ) do
    changeset =
      socket.assigns.subscription_plan_service
      |> Subscriptions.change_subscription_plan_service(subscription_plan_service_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event(
        "save",
        %{"subscription_plan_service" => subscription_plan_service_params},
        socket
      ) do
    save_subscription_plan_service(
      socket,
      socket.assigns.action,
      subscription_plan_service_params
    )
  end

  defp save_subscription_plan_service(socket, :edit, subscription_plan_service_params) do
    case Subscriptions.update_subscription_plan_service(
           socket.assigns.subscription_plan_service,
           subscription_plan_service_params
         ) do
      {:ok, subscription_plan_service} ->
        notify_parent({:saved, subscription_plan_service})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan service updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subscription_plan_service(socket, :new, subscription_plan_service_params) do
    case Subscriptions.create_subscription_plan_service(subscription_plan_service_params) do
      {:ok, subscription_plan_service} ->
        notify_parent({:saved, subscription_plan_service})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan service created successfully")
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
