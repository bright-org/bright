defmodule BrightWeb.UserSettingsLive.JobSettingComponent do
  use BrightWeb, :live_component
  alias Bright.UserJobProfiles
  alias Bright.UserJobProfiles.UserJobProfile

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.simple_form
        for={@form}
        id="job_profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="flex flex-col">
          <div class="flex flex-row gap-4 m-4">
            <.label>求職　　</.label>
            <.input
              id="user_job_profile_job_searching_on"
              type="radio"
              name={@form[:job_searching].name}
              value="true"
              checked={to_string(@form[:job_searching].value)}
              label="する"
            />
            <.input
              id="user_job_profile_job_searching_off"
              type="radio"
              name={@form[:job_searching].name}
              value="false"
              checked={to_string(@form[:job_searching].value) == "false"}
              label="しない"
            />
          </div>
          <hr>
          <%= if to_string(@form[:job_searching].value) == "true" do %>
          <div class="flex flex-row gap-4 m-4">
            <.label>求職種類</.label>
            <.input field={@form[:wish_employed]} type="checkbox" label="就職" />
            <.input field={@form[:wish_change_job]} type="checkbox" label="転職" />
            <.input field={@form[:wish_side_job]} type="checkbox" label="副業" />
            <.input field={@form[:wish_freelance]} type="checkbox" label="フリーランス" />
          </div>
          <hr>
          <div class="flex flex-row gap-4 m-4">
            <.label>就業可能日</.label>
            <div class="-mt-2">
              <.input field={@form[:availability_date]} type="date" />
            </div>
          </div>
          <hr>
          <div class="flex flex-row gap-4 m-4">
            <.label>勤務体系</.label>
            <div class="flex flex-col">
              <div class="flex flex-row gap-4">
                <.input field={@form[:office_work] } type="checkbox" label="出勤" />
                <div class="-mt-2">
                  <.input
                    field={@form[:office_pref]}
                    type="select"
                    options={Ecto.Enum.mappings(UserJobProfile, :office_pref)}
                    prompt={""}
                    disabled={to_string(@form[:office_work].value) == "false"}
                  />
                </div>
                <div class="-mt-2">
                  <.input
                    field={@form[:office_working_hours]}
                    type="select"
                    options={Ecto.Enum.mappings(UserJobProfile, :office_working_hours)}
                    prompt={""}
                    disabled={to_string(@form[:office_work].value) == "false"}
                  />
                </div>
                <.input
                  field={@form[:office_work_holidays]}
                  type="checkbox"
                  label="土日祝日も含む"
                  disabled={to_string(@form[:office_work].value) == "false"}
                />
              </div>
              <div class="flex frex-row gap-4 mt-4">
                <.input field={@form[:remote_work]} type="checkbox" label="リモート" />
                <div class="-mt-2">
                <.input
                  field={@form[:remote_working_hours]}
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :remote_working_hours)}
                  prompt={""}
                  disabled={to_string(@form[:remote_work].value) == "false"}
                />
                </div>
                <.input
                  field={@form[:remote_work_holidays]}
                  type="checkbox"
                  label="土日祝日も含む"
                  disabled={to_string(@form[:remote_work].value) == "false"}
                />
              </div>
            </div>
          </div>
          <hr>
          <div class="flex flex-row gap-4 m-4">
            <.label>月希望額</.label>
            <div class="-mt-2">
              <.input field={@form[:desired_income]} type="number" />
            </div>
          </div>
          <% end %>
        </div>

        <:actions>
          <div class="w-full mr-auto mb-4">
          <.button phx-disable-with="Saving...">保存する</.button>
          </div>
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
