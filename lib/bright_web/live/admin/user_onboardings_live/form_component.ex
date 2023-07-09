defmodule BrightWeb.Admin.UserOnboardingsLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Onboardings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_onboardings records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user_onboardings-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:completed_at]} type="datetime-local" label="Completed at" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User onboardings</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_onboardings: user_onboardings} = assigns, socket) do
    changeset = Onboardings.change_user_onboardings(user_onboardings)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_onboardings" => user_onboardings_params}, socket) do
    changeset =
      socket.assigns.user_onboardings
      |> Onboardings.change_user_onboardings(user_onboardings_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user_onboardings" => user_onboardings_params}, socket) do
    save_user_onboardings(socket, socket.assigns.action, user_onboardings_params)
  end

  defp save_user_onboardings(socket, :edit, user_onboardings_params) do
    case Onboardings.update_user_onboardings(socket.assigns.user_onboardings, user_onboardings_params) do
      {:ok, user_onboardings} ->
        notify_parent({:saved, user_onboardings})

        {:noreply,
         socket
         |> put_flash(:info, "User onboardings updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user_onboardings(socket, :new, user_onboardings_params) do
    case Onboardings.create_user_onboardings(user_onboardings_params) do
      {:ok, user_onboardings} ->
        notify_parent({:saved, user_onboardings})

        {:noreply,
         socket
         |> put_flash(:info, "User onboardings created successfully")
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
