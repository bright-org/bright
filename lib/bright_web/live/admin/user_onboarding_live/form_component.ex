defmodule BrightWeb.Admin.UserOnboardingLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Onboardings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_onboarding records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user_onboarding-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:completed_at]} type="datetime-local" label="Completed at" />
        <.input field={@form[:skill_panel_id]} type="string" label="Skill Panel Id" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User onboarding</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_onboarding: user_onboarding} = assigns, socket) do
    changeset = Onboardings.change_user_onboarding(user_onboarding)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_onboarding" => user_onboarding_params}, socket) do
    changeset =
      socket.assigns.user_onboarding
      |> Onboardings.change_user_onboarding(user_onboarding_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user_onboarding" => user_onboarding_params}, socket) do
    save_user_onboarding(socket, socket.assigns.action, user_onboarding_params)
  end

  defp save_user_onboarding(socket, :edit, user_onboarding_params) do
    case Onboardings.update_user_onboarding(
           socket.assigns.user_onboarding,
           user_onboarding_params
         ) do
      {:ok, user_onboarding} ->
        notify_parent({:saved, user_onboarding})

        {:noreply,
         socket
         |> put_flash(:info, "User onboarding updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user_onboarding(socket, :new, user_onboarding_params) do
    case Onboardings.create_user_onboarding(user_onboarding_params) do
      {:ok, user_onboarding} ->
        notify_parent({:saved, user_onboarding})

        {:noreply,
         socket
         |> put_flash(:info, "User onboarding created successfully")
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
