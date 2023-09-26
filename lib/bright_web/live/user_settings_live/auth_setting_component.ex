defmodule BrightWeb.UserSettingsLive.AuthSettingComponent do
  use BrightWeb, :live_component
  alias Bright.Repo
  alias Bright.Accounts
  alias Bright.Accounts.User
  alias Bright.Accounts.UserSubEmail
  alias BrightWeb.BrightCoreComponents, as: BrightCore
  alias BrightWeb.UserSettingsLive.UserSettingComponent

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block text-left">
      <div class="border-b border-brightGray-200 flex flex-wrap" id="mail_section">
        <div class="mt-4 mb-2">
          <p>※ 確認メールが送信され、完了後メールアドレスが変更されます</p>
        </div>
        <.form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
          phx-target={@myself}
          class="w-full"
        >
          <div class="border-brightGray-200 flex justify-between mb-4 w-full">
            <label class="flex items-center py-4">
              <span class="w-44">メールアドレス</span>
              <BrightCore.input
                field={@email_form[:email]}
                type="email"
                size="20"
                input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                required
              />
            </label>

            <div class="ml-4 mt-1 py-4 w-fit">
              <button type="submit" class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-28 hover:opacity-50">保存する</button>
            </div>
          </div>
        </.form>
      </div>

      <div class="border-b border-brightGray-200 flex flex-wrap pb-4" id="sub_mail_section">
        <div class="my-4">
          <p>※ 確認メールが送信され、完了後メールアドレスが追加されます</p>
        </div>

        <div class="w-full flex">
          <div class="w-44 py-2">
            <span>サブアドレス</span>
          </div>
          <div class="flex-1">
            <div :for={{user_sub_email, index} <- Enum.with_index(@user_sub_emails, 1)} class="sub_mail_address flex w-full py-2">
              <label class="flex items-center mr-4">
                <input type="text" size="20" name={"sub_mail_#{index}"} value={user_sub_email.email} class="bg-brightGray-50 border border-brightGray-200 px-2 py-1 rounded w-60" disabled>
              </label>
              <div class="mt-1 ml-auto w-fit">
                <button phx-click="delete_sub_email" phx-value-sub_email={user_sub_email.email} phx-target={@myself} type="button" class="mail_delete bg-white block border border-solid border-brightGray-900 cursor-pointer font-bold my-0.5 px-2 py-1 rounded select-none text-center text-brightGray-900 w-28 hover:opacity-50">削除する</button>
              </div>
            </div>

            <.form
              :if={display_add_sub_email_form?(@user_sub_emails)}
              for={@sub_email_form}
              id="sub_email_form"
              phx-submit="add_sub_email"
              phx-change="validate_sub_email"
              phx-target={@myself}
              class="sub_mail_address flex w-full py-2"
            >
              <label class="flex items-center mr-4">
                <BrightCore.input
                  field={@sub_email_form[:email]}
                  type="email"
                  size="20"
                  input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
                  required
                />
              </label>
              <div class="mt-1 ml-auto w-fit">
                <button type="submit" class="bg-brightGray-900 block border border-solid border-brightGray-900 cursor-pointer font-bold px-2 py-1 rounded select-none text-center text-white w-28 hover:opacity-50">追加する</button>
              </div>
            </.form>
          </div>
        </div>
      </div>

      <.form
        :if={Map.has_key?(assigns, :password_form)}
        class="pb-4"
        for={@password_form}
        id="password_form"
        action={~p"/users/password_reset"}
        method="post"
        phx-change="validate_password"
        phx-submit="update_password"
        phx-trigger-action={@trigger_submit}
        phx-target={@myself}
      >
        <div class="mt-4 mb-2">
          <p>※ パスワード変更後は本設定画面が閉じるため、他の変更は先に済ませておいてください</p>
        </div>
        <div class="mb-4 w-full">
          <label class="flex items-center pb-4 pt-4">
            <span class="w-44">現在のパスワード</span>
            <BrightCore.input
              field={@password_form[:current_password]}
              type="password"
              id="current_password_for_password"
              name="current_password"
              size="20"
              input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
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
                input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
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
                input_class="border border-brightGray-200 px-2 py-1 rounded w-60"
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
    user = assigns.user |> Repo.preload(:user_sub_emails)
    email_changeset = Accounts.change_user_email(user)
    sub_email_changeset = Accounts.change_new_user_sub_email(user)

    socket =
      socket
      |> assign(assigns)
      |> assign_password_form(user)
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:sub_email_form, to_form(sub_email_changeset))
      |> assign(:user_sub_emails, user.user_sub_emails)

    {:ok, socket}
  end

  # NOTE: 独自ID登録ユーザーの場合のみパスワード変更フォームを表示する
  defp assign_password_form(socket, %User{password_registered: true} = user) do
    password_changeset = Accounts.change_user_password(user)

    socket
    |> assign(:current_password, nil)
    |> assign(:password_form, to_form(password_changeset))
    |> assign(:trigger_submit, false)
  end

  defp assign_password_form(socket, _user), do: socket

  @impl true
  def handle_event(
        "validate_email",
        %{"user" => user_params},
        socket
      ) do
    email_form =
      socket.assigns.user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  @impl true
  def handle_event(
        "update_email",
        %{"user" => user_params},
        socket
      ) do
    user = socket.assigns.user

    case Accounts.apply_user_email(user, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/confirm_email/#{&1}")
        )

        send_update_after_save("本人確認メールを送信しました")

        applied_user
        |> Accounts.change_user_email(user_params)
        |> then(&{:noreply, socket |> assign(:email_form, to_form(&1))})

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  @impl true
  def handle_event(
        "validate_sub_email",
        %{"user_sub_email" => user_sub_email_params},
        socket
      ) do
    sub_email_form =
      socket.assigns.user
      |> Accounts.change_new_user_sub_email(user_sub_email_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, sub_email_form: sub_email_form)}
  end

  @impl true
  def handle_event(
        "add_sub_email",
        %{"user_sub_email" => user_sub_email_params},
        socket
      ) do
    user = socket.assigns.user

    case Accounts.apply_new_user_sub_email(user, user_sub_email_params) do
      {:ok, applied_user_sub_email} ->
        Accounts.deliver_user_add_sub_email_instructions(
          user,
          applied_user_sub_email.email,
          &url(~p"/users/confirm_sub_email/#{&1}")
        )

        send_update_after_save("サブメールアドレス追加確認メールを送信しました")

        user
        |> Accounts.change_new_user_sub_email(user_sub_email_params)
        |> then(&{:noreply, socket |> assign(:sub_email_form, to_form(&1))})

      {:error, changeset} ->
        {:noreply, assign(socket, :sub_email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  @impl true
  def handle_event(
        "delete_sub_email",
        %{"sub_email" => sub_email},
        socket
      ) do
    user = socket.assigns.user

    :ok = Accounts.delete_user_sub_email(socket.assigns.user, sub_email)

    send_update_after_save("サブメールアドレスを削除しました")

    user
    |> Repo.preload(:user_sub_emails, force: true)
    |> then(&{:noreply, socket |> assign(:user_sub_emails, &1.user_sub_emails)})
  end

  @impl true
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

  @impl true
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

  defp send_update_after_save(message) do
    send_update(
      UserSettingComponent,
      id: "user_setting_modal",
      modal_flash: %{info: message},
      action: "auth"
    )
  end

  defp display_add_sub_email_form?(user_sub_emails) do
    length(user_sub_emails) < UserSubEmail.max_sub_email_num()
  end
end
