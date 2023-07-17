defmodule BrightWeb.UserLoginLive do
  use BrightWeb, :live_view

  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
    <UserAuthComponents.header>ログイン</UserAuthComponents.header>

    <UserAuthComponents.auth_form
      for={@form}
      id="login_form"
      action={~p"/users/log_in"}
      phx-update="ignore"
    >
      <UserAuthComponents.form_section variant="left">
        <UserAuthComponents.social_auth_button variant="google" />
        <UserAuthComponents.social_auth_button variant="github" />
        <UserAuthComponents.social_auth_button variant="facebook" />
        <UserAuthComponents.social_auth_button variant="twitter" />
      </UserAuthComponents.form_section>

      <UserAuthComponents.or_text>または</UserAuthComponents.or_text>

      <UserAuthComponents.form_section variant="right">
        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" required/>

        <UserAuthComponents.input_with_label field={@form[:password]} id="password" type="password" label_text="パスワード" required>
          <:under_block>
            <UserAuthComponents.link_text_under_input href={~p"/users/reset_password"}>
              パスワードを忘れた方はこちら
            </UserAuthComponents.link_text_under_input>
          </:under_block>
        </UserAuthComponents.input_with_label>

        <UserAuthComponents.button>ログイン</UserAuthComponents.button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>

    <UserAuthComponents.link_text href={~p"/users/register"}>ユーザー新規作成はこちら</UserAuthComponents.link_text>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
