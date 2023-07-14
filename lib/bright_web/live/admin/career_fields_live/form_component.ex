defmodule BrightWeb.Admin.CareerFieldsLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Jobs

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_fields records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_fields-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:background_color]} type="text" label="Background color" />
        <.input field={@form[:button_color]} type="text" label="Button color" />
        <.input field={@form[:position]} type="number" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Career fields</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_fields: career_fields} = assigns, socket) do
    changeset = Jobs.change_career_fields(career_fields)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_fields" => career_fields_params}, socket) do
    changeset =
      socket.assigns.career_fields
      |> Jobs.change_career_fields(career_fields_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_fields" => career_fields_params}, socket) do
    save_career_fields(socket, socket.assigns.action, career_fields_params)
  end

  defp save_career_fields(socket, :edit, career_fields_params) do
    case Jobs.update_career_fields(socket.assigns.career_fields, career_fields_params) do
      {:ok, career_fields} ->
        notify_parent({:saved, career_fields})

        {:noreply,
         socket
         |> put_flash(:info, "Career fields updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_fields(socket, :new, career_fields_params) do
    case Jobs.create_career_fields(career_fields_params) do
      {:ok, career_fields} ->
        notify_parent({:saved, career_fields})

        {:noreply,
         socket
         |> put_flash(:info, "Career fields created successfully")
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
