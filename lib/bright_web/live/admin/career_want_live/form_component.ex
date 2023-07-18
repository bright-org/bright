defmodule BrightWeb.Admin.CareerWantLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_want records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_want-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:position]} type="number" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Career want</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_want: career_want} = assigns, socket) do
    changeset = Jobs.change_career_want(career_want)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_want" => career_want_params}, socket) do
    changeset =
      socket.assigns.career_want
      |> Jobs.change_career_want(career_want_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_want" => career_want_params}, socket) do
    save_career_want(socket, socket.assigns.action, career_want_params)
  end

  defp save_career_want(socket, :edit, career_want_params) do
    case Jobs.update_career_want(socket.assigns.career_want, career_want_params) do
      {:ok, career_want} ->
        notify_parent({:saved, career_want})

        {:noreply,
         socket
         |> put_flash(:info, "Career want updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_want(socket, :new, career_want_params) do
    case Jobs.create_career_want(career_want_params) do
      {:ok, career_want} ->
        notify_parent({:saved, career_want})

        {:noreply,
         socket
         |> put_flash(:info, "Career want created successfully")
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
