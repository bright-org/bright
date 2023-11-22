defmodule BrightWeb.Admin.TeamSupporterTeamLive.FormComponent do
  use BrightWeb, :live_component

  alias Bright.Teams
  alias Bright.Teams.TeamSupporterTeam

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage team_supporter_team records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="team_supporter_team-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:supportee_team_id]} type="text" label="Supportee Team ID" />
        <.input field={@form[:supporter_team_id]} type="text" label="Supporter Team ID" />
        <.input field={@form[:request_from_user_id]} type="text" label="Request from User ID" />
        <.input field={@form[:request_to_user_id]} type="text" label="Request to User ID" />
        <.input
          field={@form[:status]}
          type="select"
          label="Status"
          options={Ecto.Enum.mappings(TeamSupporterTeam, :status)}
        />
        <.input field={@form[:start_datetime]} type="datetime-local" label="Start datetime" />
        <.input field={@form[:end_datetime]} type="datetime-local" label="End datetime" />
        <.input field={@form[:request_datetime]} type="datetime-local" label="Request datetime" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Team supporter team</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{team_supporter_team: team_supporter_team} = assigns, socket) do
    changeset = Teams.change_team_supporter_team(team_supporter_team)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event(
        "validate",
        %{"team_supporter_team" => team_supporter_team_params},
        socket
      ) do
    changeset =
      socket.assigns.team_supporter_team
      |> Teams.change_team_supporter_team(team_supporter_team_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"team_supporter_team" => team_supporter_team_params}, socket) do
    save_team_supporter_team(socket, socket.assigns.action, team_supporter_team_params)
  end

  defp save_team_supporter_team(socket, :edit, team_supporter_team_params) do
    case Teams.update_team_supporter_team(
           socket.assigns.team_supporter_team,
           team_supporter_team_params
         ) do
      {:ok, team_supporter_team} ->
        notify_parent({:saved, team_supporter_team})

        {:noreply,
         socket
         |> put_flash(:info, "Team supporter team updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_team_supporter_team(socket, :new, team_supporter_team_params) do
    case Teams.create_team_supporter_team(team_supporter_team_params) do
      {:ok, team_supporter_team} ->
        notify_parent({:saved, team_supporter_team})

        {:noreply,
         socket
         |> put_flash(:info, "Team supporter team created successfully")
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
