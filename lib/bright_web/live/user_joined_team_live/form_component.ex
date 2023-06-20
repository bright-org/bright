defmodule BrightWeb.UserJoinedTeamLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Teams

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage user_joined_team records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="user_joined_team-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:bright_user_id]} type="number" label="Bright user" />
        <.input field={@form[:team_id]} type="number" label="Team" />
        <.input field={@form[:is_auther]} type="checkbox" label="Is auther" />
        <.input field={@form[:is_primary_team]} type="checkbox" label="Is primary team" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User joined team</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{user_joined_team: user_joined_team} = assigns, socket) do
    changeset = Teams.change_user_joined_team(user_joined_team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_joined_team" => user_joined_team_params}, socket) do
    changeset =
      socket.assigns.user_joined_team
      |> Teams.change_user_joined_team(user_joined_team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user_joined_team" => user_joined_team_params}, socket) do
    save_user_joined_team(socket, socket.assigns.action, user_joined_team_params)
  end

  defp save_user_joined_team(socket, :edit, user_joined_team_params) do
    case Teams.update_user_joined_team(socket.assigns.user_joined_team, user_joined_team_params) do
      {:ok, user_joined_team} ->
        notify_parent({:saved, user_joined_team})

        {:noreply,
         socket
         |> put_flash(:info, "User joined team updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_user_joined_team(socket, :new, user_joined_team_params) do
    case Teams.create_user_joined_team(user_joined_team_params) do
      {:ok, user_joined_team} ->
        notify_parent({:saved, user_joined_team})

        {:noreply,
         socket
         |> put_flash(:info, "User joined team created successfully")
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
