defmodule BrightWeb.UserResetPasswordLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
      <h1 class="font-bold text-center text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">パスワードリセット</span>
      </h1>

      <p class="mt-8 mx-auto text-sm w-fit">新しいパスワードを入力してください。</p>

      <.form
        :let={_f}
        for={@form}
        id="reset_password_form"
        class="flex mt-8 mx-auto relative"
        phx-submit="reset_password"
        phx-change="validate"
      >
        <section class="flex flex-col mx-auto">
          <label for="email" class="mt-4">
            <span class="block font-bold mb-2 text-xs">新しいパスワード</span>
            <UserAuthComponents.input field={@form[:password]} id="password" type="password" required />
          </label>

          <label for="re_password" class="mt-4">
            <span class="block font-bold mb-2 text-xs">（確認）新しいパスワード</span>
            <UserAuthComponents.input field={@form[:password_confirmation]} id="re_password" type="password" required />
          </label>

          <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold max-w-xs mt-12 px-4 py-2 rounded select-none text-white w-full hover:opacity-50">パスワードをリセットする</button>
        </section>
      </.form>
    """
  end

  def mount(params, _session, socket) do
    socket = assign_user_and_token(socket, params)

    form_source =
      case socket.assigns do
        %{user: user} ->
          Accounts.change_user_password(user)

        _ ->
          %{}
      end

    {:ok, assign_form(socket, form_source), temporary_assigns: [form: nil]}
  end

  # Do not log in the user after reset password to avoid a
  # leaked token giving the user access to the account.
  def handle_event("reset_password", %{"user" => user_params}, socket) do
    case Accounts.reset_user_password(socket.assigns.user, user_params) do
      {:ok, _} ->
        {:noreply,
         socket
         |> redirect(to: ~p"/users/finish_reset_password")}

      {:error, changeset} ->
        {:noreply, assign_form(socket, Map.put(changeset, :action, :insert))}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_password(socket.assigns.user, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_user_and_token(socket, %{"token" => token}) do
    if user = Accounts.get_user_by_reset_password_token(token) do
      assign(socket, user: user, token: token)
    else
      socket
      |> put_flash(:error, "Reset password link is invalid or it has expired.")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
