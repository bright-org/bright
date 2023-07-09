defmodule BrightWeb.Admin.OnboardingWantLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Onboardings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage onboarding_want records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="onboarding_want-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:position]} type="number" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Onboarding want</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{onboarding_want: onboarding_want} = assigns, socket) do
    changeset = Onboardings.change_onboarding_want(onboarding_want)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"onboarding_want" => onboarding_want_params}, socket) do
    changeset =
      socket.assigns.onboarding_want
      |> Onboardings.change_onboarding_want(onboarding_want_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"onboarding_want" => onboarding_want_params}, socket) do
    save_onboarding_want(socket, socket.assigns.action, onboarding_want_params)
  end

  defp save_onboarding_want(socket, :edit, onboarding_want_params) do
    case Onboardings.update_onboarding_want(socket.assigns.onboarding_want, onboarding_want_params) do
      {:ok, onboarding_want} ->
        notify_parent({:saved, onboarding_want})

        {:noreply,
         socket
         |> put_flash(:info, "Onboarding want updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_onboarding_want(socket, :new, onboarding_want_params) do
    case Onboardings.create_onboarding_want(onboarding_want_params) do
      {:ok, onboarding_want} ->
        notify_parent({:saved, onboarding_want})

        {:noreply,
         socket
         |> put_flash(:info, "Onboarding want created successfully")
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
