defmodule BrightWeb.UserForgotPasswordLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
    <UserAuthComponents.header>パスワードを忘れた方へ</UserAuthComponents.header>

    <UserAuthComponents.description>
      パスワードをリセットするリンクをメールに送ります。<br>登録しているユーザーのメールアドレスを入力してください。
    </UserAuthComponents.description>

    <UserAuthComponents.auth_form
      for={@form}
      id="reset_password_form"
      phx-submit="send_email"
    >
      <UserAuthComponents.form_section variant="center">
        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" required/>

        <UserAuthComponents.button variant="mt-sm">パスワードリセット用リンクを送信</UserAuthComponents.button>

        <UserAuthComponents.link_button href={~p"/users/log_in"}>戻る</UserAuthComponents.link_button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    {:noreply, socket |> redirect(to: ~p"/users/send_reset_password_url")}
  end
end
