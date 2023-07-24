defmodule BrightWeb.UserSettingsLive.JobSettingComponent do
  use BrightWeb, :live_component
  alias Bright.UserJobProfiles

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        求職
      </.header>

      <.simple_form
        for={@form}
        id="job_profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:desired_income]} type="number" label="希望月収" />
        <:actions>
          <.button phx-disable-with="Saving...">Save User Job profile</.button>
        </:actions>
      </.simple_form>

    </div>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    user_job_profile =
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)

    changeset = UserJobProfiles.change_user_job_profile(user_job_profile)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(user_job_profile: user_job_profile)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user_job_profile" => user_job_profile_params}, socket) do
    changeset =
      socket.assigns.user_job_profile
      |> UserJobProfiles.change_user_job_profile(user_job_profile_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"user_job_profile" => user_job_profile_params}, socket) do
    save_user_job_profile(socket, socket.assigns.action, user_job_profile_params)
  end

  defp save_user_job_profile(socket, :edit, user_job_profile_params) do
    case UserJobProfiles.update_user_job_profile(
           socket.assigns.user_job_profile,
           user_job_profile_params
         ) do
      {:ok, user_job_profile} ->
        notify_parent({:saved, user_job_profile})

        socket
        |> put_flash(:info, "User Job profile updated successfully")
        |> push_patch(to: "/settings/job")
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
