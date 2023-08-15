defmodule BrightWeb.UserResetPasswordLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
    <UserAuthComponents.header>パスワードリセット</UserAuthComponents.header>

    <UserAuthComponents.description>新しいパスワードを入力してください。</UserAuthComponents.description>

    <UserAuthComponents.auth_form
      for={@form}
      id="reset_password_form"
      phx-submit="reset_password"
      phx-change="validate"
    >
      <UserAuthComponents.form_section variant="center">
        <UserAuthComponents.input_with_label field={@form[:password]} id="password" type="password" label_text="新しいパスワード" required/>

        <UserAuthComponents.input_with_label field={@form[:password_confirmation]} id="re_password" type="password" label_text="（確認）新しいパスワード" required/>

        <UserAuthComponents.button>パスワードをリセットする</UserAuthComponents.button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>
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
         |> put_flash(:info, "パスワードをリセットしました")
         |> redirect(to: ~p"/users/log_in")}

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
      |> put_flash(:error, "リンクが無効であるか期限が切れています")
      |> redirect(to: ~p"/users/log_in")
    end
  end

  defp assign_form(socket, %{} = source) do
    assign(socket, :form, to_form(source, as: "user"))
  end
end
