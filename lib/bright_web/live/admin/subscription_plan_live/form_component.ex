defmodule BrightWeb.Admin.SubscriptionPlanLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subscription_plan records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subscription_plan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:plan_code]} type="text" label="Plan code" />
        <.input field={@form[:name_jp]} type="text" label="Name jp" />
        <.input field={@form[:create_teams_limit]} type="number" label="Create teams limit" />
        <.input field={@form[:create_enable_hr_functions_teams_limit]} type="number" label="Create enable hr functions teams limit" />
        <.input field={@form[:team_members_limit]} type="number" label="Team members limit" />
        <.input field={@form[:available_contract_end_datetime]} type="datetime-local" label="Available contract end datetime" />
        <.input field={@form[:free_trial_priority]} type="number" label="Free trial priority" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subscription plan</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subscription_plan: subscription_plan} = assigns, socket) do
    changeset = Subscriptions.change_subscription_plan(subscription_plan)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"subscription_plan" => subscription_plan_params}, socket) do
    changeset =
      socket.assigns.subscription_plan
      |> Subscriptions.change_subscription_plan(subscription_plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subscription_plan" => subscription_plan_params}, socket) do
    save_subscription_plan(socket, socket.assigns.action, subscription_plan_params)
  end

  defp save_subscription_plan(socket, :edit, subscription_plan_params) do
    case Subscriptions.update_subscription_plan(
           socket.assigns.subscription_plan,
           subscription_plan_params
         ) do
      {:ok, subscription_plan} ->
        notify_parent({:saved, subscription_plan})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subscription_plan(socket, :new, subscription_plan_params) do
    case Subscriptions.create_subscription_plan(subscription_plan_params) do
      {:ok, subscription_plan} ->
        notify_parent({:saved, subscription_plan})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription plan created successfully")
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
