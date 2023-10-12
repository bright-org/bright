defmodule BrightWeb.Admin.CareerFieldLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.CareerFields

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage career_field records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="career_field-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name_en]} type="text" label="Name English" />
        <.input field={@form[:name_ja]} type="text" label="Name Japanese" />
        <.input field={@form[:position]} type="number" label="Position" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Career field</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{career_field: career_field} = assigns, socket) do
    changeset = CareerFields.change_career_field(career_field)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"career_field" => career_field_params}, socket) do
    changeset =
      socket.assigns.career_field
      |> CareerFields.change_career_field(career_field_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"career_field" => career_field_params}, socket) do
    save_career_field(socket, socket.assigns.action, career_field_params)
  end

  defp save_career_field(socket, :edit, career_field_params) do
    case CareerFields.update_career_field(socket.assigns.career_field, career_field_params) do
      {:ok, career_field} ->
        notify_parent({:saved, career_field})

        {:noreply,
         socket
         |> put_flash(:info, "Career field updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_career_field(socket, :new, career_field_params) do
    case CareerFields.create_career_field(career_field_params) do
      {:ok, career_field} ->
        notify_parent({:saved, career_field})

        {:noreply,
         socket
         |> put_flash(:info, "Career field created successfully")
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
