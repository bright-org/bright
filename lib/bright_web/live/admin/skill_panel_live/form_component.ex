defmodule BrightWeb.Admin.SkillPanelLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.SkillPanels

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage skill_panel records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="skill_panel-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:locked_date]} type="date" label="Locked date" />
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Skill panel</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{skill_panel: skill_panel} = assigns, socket) do
    changeset = SkillPanels.change_skill_panel(skill_panel)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"skill_panel" => skill_panel_params}, socket) do
    changeset =
      socket.assigns.skill_panel
      |> SkillPanels.change_skill_panel(skill_panel_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"skill_panel" => skill_panel_params}, socket) do
    save_skill_panel(socket, socket.assigns.action, skill_panel_params)
  end

  defp save_skill_panel(socket, :edit, skill_panel_params) do
    case SkillPanels.update_skill_panel(socket.assigns.skill_panel, skill_panel_params) do
      {:ok, skill_panel} ->
        notify_parent({:saved, skill_panel})

        {:noreply,
         socket
         |> put_flash(:info, "Skill panel updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_skill_panel(socket, :new, skill_panel_params) do
    case SkillPanels.create_skill_panel(skill_panel_params) do
      {:ok, skill_panel} ->
        notify_parent({:saved, skill_panel})

        {:noreply,
         socket
         |> put_flash(:info, "Skill panel created successfully")
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
