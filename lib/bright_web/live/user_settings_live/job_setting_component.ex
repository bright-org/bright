defmodule BrightWeb.UserSettingsLive.JobSettingComponent do
  use BrightWeb, :live_component
  alias Bright.UserJobProfiles
  alias Bright.UserJobProfiles.UserJobProfile
  alias BrightWeb.UserSettingsLive.UserSettingComponent
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <.form
        for={@form}
        id="job_profile-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <div class="border-b border-brightGray-200 flex flex-wrap">
          <div class="flex py-4">
            <span class="w-24 text-start">求職</span>
            <BrightCore.input
              id="user_job_profile_job_searching_on"
              type="radio"
              name={@form[:job_searching].name}
              value="true"
              checked={to_string(@form[:job_searching].value)}
              label="する"
            />
            <BrightCore.input
              id="user_job_profile_job_searching_off"
              container_class="ml-4"
              type="radio"
              name={@form[:job_searching].name}
              value="false"
              checked={to_string(@form[:job_searching].value) == "false"}
              label="しない"
            />
          </div>
        </div>

        <%= if to_string(@form[:job_searching].value) == "true" do %>
          <div class="border-b border-brightGray-200">
            <BrightCore.input
              field={@form[:desired_income]}
              container_class="py-4 w-full"
              label_class="py-1 w-24 text-start"
              after_label_class="ml-1"
              type="number"
              label="希望年収"
              after_label="万円以上"
            />
          </div>
          <div class="border-b border-brightGray-200 flex flex-wrap">
            <div class="flex pt-4">
              <div class="flex flex-col mt-2 text-start">
                <span class="pt-1 w-24">希望する</span>
                <span class="pb-1 w-24">形態</span>
              </div>
              <div class="py-4 flex">
              <BrightCore.input
                field={@form[:wish_employed]}
                type="checkbox"
                label="就職"
              />
              <BrightCore.input
                field={@form[:wish_change_job]}
                container_class="ml-4"
                type="checkbox"
                label="転職"
              />
              <BrightCore.input
                field={@form[:wish_side_job]}
                container_class="ml-4"
                type="checkbox"
                label="副業"
              />
              <BrightCore.input
                field={@form[:wish_freelance]}
                container_class="ml-4"
                type="checkbox"
                label="フリーランス"
              />
              </div>
            </div>
            <div class="pl-24 pb-4 flex">
              <span class="">※求職優先の方は、すべて選択するとスカウト検索がヒットしやすくなります</span>
            </div>
          </div>

          <div class="flex flex-wrap py-4 w-full">
            <div class="flex flex-col text-start">
              <span class="pt-1 w-24">希望する</span>
              <span class="pb-1 w-24">勤務体系</span>
            </div>
            <div>
            <div class="flex items-center">
                <BrightCore.input
                  name={@form[:work_style].name}
                  checked={@form[:work_style].value == "both"}
                  value="both"
                  label_class="w-20 text-left"
                  type="radio"
                  label="どちらでも可"
                />
              </div>
              <div class="flex items-center">
                <BrightCore.input
                  name={@form[:work_style].name}
                  checked={@form[:work_style].value == "office"}
                  value="office"
                  label_class="w-24 text-left"
                  type="radio"
                  label="出勤のみ可"
                />
                <BrightCore.input
                  field={@form[:office_pref]}
                  input_class="w-40"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :office_pref)}
                  prompt="希望勤務地"
                  disabled={@form[:work_style].value not in ["office", "both"]}
                />
                <BrightCore.input
                  field={@form[:office_working_hours]}
                  input_class="w-40"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :office_working_hours)}
                  prompt="希望勤務時間"
                  disabled={@form[:work_style].value not in ["office", "both"]}
                />
                <BrightCore.input
                  field={@form[:office_work_holidays]}
                  container_class="ml-4"
                  type="checkbox"
                  label="土日祝の稼働も含む"
                  disabled={@form[:work_style].value not in ["office", "both"]}
                  label_class={if @form[:work_style].value not in ["office", "both"], do: "text-pureGray-600"}
                />
              </div>

              <div class="flex items-center mt-2">
                <BrightCore.input
                  name={@form[:work_style].name}
                  checked={@form[:work_style].value == "remote"}
                  value="remote"
                  label_class="w-24 text-left"
                  type="radio"
                  label="リモートのみ可"
                />
                <BrightCore.input
                  field={@form[:remote_working_hours]}
                  input_class="w-40"
                  type="select"
                  options={Ecto.Enum.mappings(UserJobProfile, :remote_working_hours)}
                  prompt="希望勤務時間"
                  disabled={@form[:work_style].value not in ["remote", "both"]}
                />
                <BrightCore.input
                  field={@form[:remote_work_holidays]}
                  container_class="ml-4"
                  label_class={if @form[:work_style].value not in ["remote", "both"], do: "text-pureGray-600"}
                  type="checkbox"
                  label="土日祝の稼働も含む"
                  disabled={@form[:work_style].value not in ["remote", "both"]}
                />
              </div>
            </div>
          </div>
        <% end %>

        <div class="flex mt-8 mx-auto w-fit">
          <BrightCore.button phx-disable-with="Saving...">保存する</BrightCore.button>
        </div>
      </.form>
    </li>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    user_job_profile = UserJobProfiles.get_user_job_profile_by_user_id!(user.id)

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

    send_update(
      UserSettingComponent,
      id: "user_setting_modal",
      modal_flash: %{},
      action: "job"
    )

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
        send_update(UserSettingComponent,
          id: "user_setting_modal",
          modal_flash: %{info: "保存しました"},
          action: "job"
        )

        socket
        |> assign(:user_job_profile, user_job_profile)
        |> assign_form(UserJobProfiles.change_user_job_profile(user_job_profile))
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
