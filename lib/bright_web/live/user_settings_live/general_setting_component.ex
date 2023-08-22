defmodule BrightWeb.UserSettingsLive.GeneralSettingComponent do
  use BrightWeb, :live_component

  alias Bright.Accounts
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
              <.inputs_for :let={ff} field={@form[:user_profile]}>
                <BrightCore.input field={ff[:title]} type="text" size="20" input_class="px-2 py-1 rounded w-60" />
              </.inputs_for>
            </label>

            <label class="flex items-center pt-4 pb-2">
              <span class="w-32">GitHub</span>
              <.inputs_for :let={ff} field={@form[:user_profile]}>
                <BrightCore.input field={ff[:github_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://github.com/" />
              </.inputs_for>
            </label>

            <label class="flex items-center py-2">
              <span class="w-32">Twitter</span>
              <.inputs_for :let={ff} field={@form[:user_profile]}>
                <BrightCore.input field={ff[:twitter_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://twitter.com/" />
              </.inputs_for>
            </label>

            <label class="flex items-center pt-2 pb-4">
              <span class="w-32">Facebook</span>
              <.inputs_for :let={ff} field={@form[:user_profile]}>
                <BrightCore.input field={ff[:facebook_url]} type="text" size="20" input_class="px-2 py-1 rounded w-60 placeholder-brightGray-100" placeholder="https://www.facebook.com/" />
              </.inputs_for>
            </label>
          </div>

          <div class="relative py-4 w-1/2">
            <p>アイコン</p>
            <label for={@uploads.icon.ref} class={[
              "absolute bg-20 block cursor-pointer h-20 left-1/2 -ml-10 -mt-10 top-1/2 w-20",
              length(@uploads.icon.entries) == 0 && "bg-bgAddAvatar"
              ]}>
              <.live_file_input upload={@uploads.icon} class="hidden" />

              <%= for entry <- @uploads.icon.entries do %>
                <.live_img_preview entry={entry} class="cursor-pointer h-20 w-20 rounded-full" />
              <% end %>
            </label>
          </div>
        </div>

        <div class="text-left">
          <label class="flex py-4 w-full">
            <span class="py-1 w-32">自己紹介</span>
            <.inputs_for :let={ff} field={@form[:user_profile]}>
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

  # TODO
  # アイコン画像のバリデーション
  # アイコン画像の保存処理
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

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case socket.assigns.user
         |> Bright.Repo.preload(:user_profile)
         |> Accounts.update_user_with_user_profile(user_params) do
      {:ok, _user} ->
        send_update(UserSettingComponent,
          id: "user_setting_modal",
          modal_flash: %{info: "保存しました"},
          action: "general"
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
