defmodule BrightWeb.Admin.SubscriptionUserPlanLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Subscriptions
  alias Bright.Subscriptions.SubscriptionUserPlan

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage subscription_user_plan records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="subscription_user_plan-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:user_id]} type="text" label="User ID" />
        <.input field={@form[:company_name]} type="text" label="Company Name" />
        <.input field={@form[:pic_name]} type="text" label="PIC Name" />
        <.input field={@form[:phone_number]} type="text" label="Phone Number" />
        <.input
            field={@form[:subscription_plan_id]}
            type="select"
            label="Plan"
            options={@subscription_plans}
          />
        <.input
          field={@form[:subscription_status]}
          type="select"
          label="Subscription status"
          options={Ecto.Enum.mappings(SubscriptionUserPlan, :subscription_status)}
        />
        <.input field={@form[:subscription_start_datetime]} type="datetime-local" label="Subscription start datetime" />
        <.input field={@form[:subscription_end_datetime]} type="datetime-local" label="Subscription end datetime" />
        <.input field={@form[:trial_start_datetime]} type="datetime-local" label="Trial start datetime" />
        <.input field={@form[:trial_end_datetime]} type="datetime-local" label="Trial end datetime" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Subscription user plan</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{subscription_user_plan: subscription_user_plan} = assigns, socket) do
    changeset = Subscriptions.change_subscription_user_plan(subscription_user_plan)

    plans =
      Subscriptions.list_subscription_plans()
      |> Enum.map(&[key: &1.name_jp, value: &1.id])

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:subscription_plans, plans)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"subscription_user_plan" => subscription_user_plan_params},
        socket
      ) do
    changeset =
      socket.assigns.subscription_user_plan
      |> Subscriptions.change_subscription_user_plan(subscription_user_plan_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"subscription_user_plan" => subscription_user_plan_params}, socket) do
    save_subscription_user_plan(socket, socket.assigns.action, subscription_user_plan_params)
  end

  defp save_subscription_user_plan(socket, :edit, subscription_user_plan_params) do
    case Subscriptions.update_subscription_user_plan(
           socket.assigns.subscription_user_plan,
           subscription_user_plan_params
         ) do
      {:ok, subscription_user_plan} ->
        notify_parent({:saved, subscription_user_plan})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription user plan updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_subscription_user_plan(socket, :new, subscription_user_plan_params) do
    case Subscriptions.create_subscription_user_plan(subscription_user_plan_params) do
      {:ok, subscription_user_plan} ->
        notify_parent({:saved, subscription_user_plan})

        {:noreply,
         socket
         |> put_flash(:info, "Subscription user plan created successfully")
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
