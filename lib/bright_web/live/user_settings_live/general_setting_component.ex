defmodule BrightWeb.UserSettingsLive.GeneralSettingComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
  alias Bright.UserProfiles
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  alias BrightWeb.UserSettingsLive.UserSettingComponent

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <.form id="general_setting_form" :let={f} for={@form} phx-target={@myself} phx-submit="save" phx-change="validate">
        <div class="border-b border-brightGray-200 flex flex-wrap text-left">
          <div class="w-1/2">
            <label class="border-b border-brightGray-200 flex items-center py-4">
              <span class="w-32">ハンドル名</span>
              <BrightCore.input field={f[:name]} type="text" size="20" input_class="px-2 py-1 rounded w-60" />
            </label>
            <label class="border-b border-brightGray-200 flex items-center py-4">
              <span class="w-32">称号</span>
              <.inputs_for :let={ff} field={f[:user_profile]}>
                <BrightCore.input field={ff[:title]} type="text" size="20" input_class="px-2 py-1 rounded w-60" />
              </.inputs_for>
            </label>

            <label class="flex items-center pt-4 pb-2">
              <span class="w-32">GitHub</span>
              <.inputs_for :let={ff} field={f[:user_profile]}>
                <BrightCore.input field={ff[:github_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://github.com/" />
              </.inputs_for>
            </label>

            <label class="flex items-center py-2">
              <span class="w-32">Twitter</span>
              <.inputs_for :let={ff} field={f[:user_profile]}>
                <BrightCore.input field={ff[:twitter_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://twitter.com/" />
              </.inputs_for>
            </label>

            <label class="flex items-center pt-2 pb-4">
              <span class="w-32">Facebook</span>
              <.inputs_for :let={ff} field={f[:user_profile]}>
                <BrightCore.input field={ff[:facebook_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://www.facebook.com/" />
              </.inputs_for>
            </label>
          </div>

          <div class="relative py-4 w-1/2">
            <p>アイコン</p>
            <.error :for={err <- upload_errors(@uploads.icon)}><%= upload_error_to_string(err) %></.error>
            <%= for entry <- @uploads.icon.entries do %>
              <.error :for={err <- upload_errors(@uploads.icon, entry)}><%= upload_error_to_string(err) %></.error>
            <% end %>
            <.inputs_for :let={ff} field={f[:user_profile]}>
              <label for={@uploads.icon.ref} class={[
                "absolute bg-20 block cursor-pointer h-20 left-1/2 -ml-10 -mt-10 top-1/2 w-20",
                Enum.empty?(@uploads.icon.entries) && is_nil(Phoenix.HTML.Form.input_value(ff, :icon_file_path)) && "bg-bgAddAvatar"
              ]}>
                <.live_file_input upload={@uploads.icon} class="hidden" />
                <img
                  src={UserProfiles.icon_url(Phoenix.HTML.Form.input_value(ff, :icon_file_path))}
                  :if={Enum.empty?(@uploads.icon.entries) && !is_nil(Phoenix.HTML.Form.input_value(ff, :icon_file_path))}
                  class="cursor-pointer h-20 w-20 rounded-full"
                />
                <%= for entry <- @uploads.icon.entries do %>
                  <.live_img_preview entry={entry} class="cursor-pointer h-20 w-20 rounded-full" />
                <% end %>
              </label>
            </.inputs_for>
          </div>
        </div>

        <div class="text-left">
          <label class="flex py-4 w-full">
            <span class="py-1 w-32">自己紹介</span>
            <.inputs_for :let={ff} field={f[:user_profile]}>
              <BrightCore.input type="textarea" field={ff[:detail]} div_class="w-full" input_class="w-full" rows="3" cols="20" />
            </.inputs_for>
          </label>
        </div>

        <div class="flex mt-8 relative">
          <button type="submit" class="bg-brightGray-900 border block border-solid border-brightGray-900 cursor-pointer font-bold mx-auto px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50">保存する</button>
        </div>
      </.form>
    </li>
    """
  end

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset =
      user
      |> Bright.Repo.preload(:user_profile)
      |> Accounts.change_user_with_user_profile()

    {:ok,
     socket
     |> assign(assigns)
     |> allow_upload(:icon, accept: ~w(.jpg .jpeg .png), max_file_size: 2_000_000)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Bright.Repo.preload(:user_profile)
      |> Accounts.change_user_with_user_profile(user_params)
      |> Map.put(:action, :validate)

    send_update_when_validate()

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    socket
    |> handle_uploaded_entries(user_params, uploaded_entries(socket, :icon))
    |> case do
      {:ok, user} ->
        send_update_after_save(user)
        {:noreply, socket |> assign_form(Accounts.change_user_with_user_profile(user))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  # NOTE: ファイルアップロードあり
  defp handle_uploaded_entries(socket, user_params, {[_ | _] = entries, []}) do
    entry = List.first(entries)

    consume_uploaded_entry(socket, entry, fn %{path: path} ->
      {:ok,
       update_user_with_user_profile(
         socket,
         merge_icon_file_path(user_params, entry),
         path
       )}
    end)
  end

  # NOTE: ファイルアップロードなし
  defp handle_uploaded_entries(socket, user_params, _) do
    update_user_with_user_profile(socket, user_params, nil)
  end

  # NOTE: handle_event("save") と合わせて send_update_after とする
  defp send_update_when_validate do
    send_update_after(
      UserSettingComponent,
      [
        id: "user_setting_modal",
        modal_flash: %{},
        action: "general"
      ],
      500
    )
  end

  # NOTE: 即時更新してしまうと update 後の allow_upload でエラーになることがあるので 500ms 程度待つ
  defp send_update_after_save(user) do
    send_update_after(
      UserSettingComponent,
      [
        id: "user_setting_modal",
        modal_flash: %{info: "保存しました"},
        action: "general",
        current_user: user
      ],
      500
    )
  end

  defp merge_icon_file_path(user_params, entry) do
    Map.merge(
      user_params,
      %{
        "user_profile" => %{
          "icon_file_path" => UserProfiles.build_icon_path(entry.client_name)
        }
      },
      fn _key, user_param, icon_param -> Map.merge(user_param, icon_param) end
    )
  end

  defp update_user_with_user_profile(socket, user_params, uploaded_icon_file_path) do
    socket.assigns.user
    |> Bright.Repo.preload(:user_profile)
    |> Accounts.update_user_with_user_profile(user_params, uploaded_icon_file_path)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
