defmodule BrightWeb.UserSettingsLive.AuthSettingComponent do
  use BrightWeb, :live_component
  alias Bright.Accounts
  alias Bright.Accounts.User
  alias BrightWeb.BrightCoreComponents, as: BrightCore

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block text-left">
      <%!-- TODO: サブメールアドレスが実装されたら border-b を追加する --%>
      <div class="border-brightGray-200 flex flex-wrap" id="mail_section">
        <div class="border-b border-brightGray-200 flex justify-between mb-4 w-full">
          <label class="flex items-center py-4">
            <span class="w-44">メールアドレス</span>
            <input type="text" size="20" name="mail" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>

          <div class="ml-4 mt-1 py-4 w-fit">
            <a class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-28 hover:opacity-50">保存する</a>
          </div>
        </div>

        <%!-- α版では未実装 --%>
        <%!-- <div class="sub_mail_address flex pb-4 w-9/12">
          <label class="flex items-center mr-4">
            <span class="flex items-center justify-between w-44">サブアドレス</span>
            <input type="text" size="20" name="sub_mail_0" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>
          <button type="button" class="mail_delete bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">削除する</button>
          <button type="button" class="hidden mail_add bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">追加する</button>
        </div>

        <div class="sub_mail_address flex pb-4 w-9/12">
          <label class="flex items-center mr-4 pl-44">
            <input type="text" size="20" name="sub_mail_0" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>
          <button type="button" class="mail_delete bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">削除する</button>
          <button type="button" class="hidden mail_add bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">追加する</button>
        </div>

        <div class="sub_mail_address flex pb-4 w-9/12">
          <label class="flex items-center mr-4 pl-44">
            <input type="text" size="20" name="sub_mail_0" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>
          <button type="button" class="mail_delete bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">削除する</button>
          <button type="button" class="hidden mail_add bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">追加する</button>
        </div>

        <div class="mt-1 ml-auto pb-4 w-fit">
          <a class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-28 hover:opacity-50">保存する</a>
        </div> --%>
      </div>

      <.form
        :if={Map.has_key?(assigns, :password_form)}
        for={@password_form}
        id="password_form"
        action={~p"/users/password_reset"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
        phx-target={@myself}
      >
        <BrightCore.input
          field={@password_form[:email]}
          type="hidden"
          id="hidden_user_email"
          value={@current_email}
        />
        <div class="mb-4 w-full">
          <label class="flex items-center pb-4 pt-4">
            <span class="w-44">現在のパスワード</span>
            <BrightCore.input
              field={@password_form[:current_password]}
              type="password"
              id="current_password_for_password"
              name="current_password"
              size="20"
              input_class="border border-brightGray-200 px-2 py-1 rounded w-48"
              value={@current_password}
              required
            />
          </label>
        </div>
        <div class="relative">
          <div class="mb-2 w-full">
            <label class="flex items-center">
              <span class="w-44">新しいパスワード</span>
              <BrightCore.input
                field={@password_form[:password]}
                type="password"
                size="20"
                input_class="border border-brightGray-200 px-2 py-1 rounded w-48"
                required
              />
            </label>
          </div>

          <div class="w-full">
            <label class="flex items-center">
              <span class="w-44">新しいパスワード（確認）</span>
              <BrightCore.input
                field={@password_form[:password_confirmation]}
                type="password"
                size="20"
                input_class="border border-brightGray-200 px-2 py-1 rounded w-48"
              />
            </label>
          </div>
          <div class="absolute right-0 bottom-0 w-fit">
            <button type="submit" class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-28 hover:opacity-50">保存する</button>
          </div>
        </div>
      </.form>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    user = assigns.user
    #  email_changeset = Accounts.change_user_email(user)

    socket =
      socket
      |> assign(assigns)
      |> assign_password_form(user)
      # |> assign(:current_password, nil)
      # |> assign(:email_form_current_password, nil)
      |> assign(:current_email, user.email)
      |> assign(:trigger_submit, false)

    # |> assign(:email_form, to_form(email_changeset))

    {:ok, socket}
  end

  # NOTE: 独自ID登録ユーザーの場合のみパスワード変更フォームを表示する
  defp assign_password_form(socket, %User{password_registered: true} = user) do
    password_changeset = Accounts.change_user_password(user)

    socket
    |> assign(:current_password, nil)
    |> assign(:password_form, to_form(password_changeset))
  end

  defp assign_password_form(socket, _user) do
    socket
  end

  def handle_event(
        "validate_password",
        %{"current_password" => password, "user" => user_params},
        socket
      ) do
    password_form =
      socket.assigns.user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event(
        "update_password",
        %{"current_password" => password, "user" => user_params},
        socket
      ) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user_password_before_submit(password, user_params)

    case changeset do
      %Ecto.Changeset{valid?: true} ->
        {:noreply, assign(socket, trigger_submit: true, password_form: changeset |> to_form())}

      _ ->
        {:noreply,
         assign(socket,
           password_form: changeset |> Map.put(:action, :validate) |> to_form(),
           current_password: password
         )}
    end
  end
end
