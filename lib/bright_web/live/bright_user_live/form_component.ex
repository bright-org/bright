defmodule BrightWeb.BrightUserLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Users

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage bright_user records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="bright_user-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:handle_name]} type="text" label="Handle name" />
        <.input field={@form[:email]} type="text" label="Email" />
        <.input field={@form[:password]} type="text" label="Password" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Bright user</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{bright_user: bright_user} = assigns, socket) do
    changeset = Users.change_bright_user(bright_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"bright_user" => bright_user_params}, socket) do
    changeset =
      socket.assigns.bright_user
      |> Users.change_bright_user(bright_user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"bright_user" => bright_user_params}, socket) do
    save_bright_user(socket, socket.assigns.action, bright_user_params)
  end

  defp save_bright_user(socket, :edit, bright_user_params) do
    case Users.update_bright_user(socket.assigns.bright_user, bright_user_params) do
      {:ok, bright_user} ->
        notify_parent({:saved, bright_user})

        {:noreply,
         socket
         |> put_flash(:info, "Bright user updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_bright_user(socket, :new, bright_user_params) do
    case Users.create_bright_user(bright_user_params) do
      {:ok, bright_user} ->
        notify_parent({:saved, bright_user})

        {:noreply,
         socket
         |> put_flash(:info, "Bright user created successfully")
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
