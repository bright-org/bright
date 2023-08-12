defmodule BrightWeb.UserConfirmationInstructionsLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
    <UserAuthComponents.header>確認メールが届かなかった方へ</UserAuthComponents.header>

    <UserAuthComponents.description>
      確認メールを再度送信します。
      <br>
      登録時に使用したメールアドレスを入力してください。
      <br>
      <br>
      <span class="text-xs">
        メールが届かない場合は、Brightからのメールが受信できるように
        <br>
        ドメイン指定受信で「bright-fun.org」を許可するように設定してください。
      </span>
    </UserAuthComponents.description>

    <UserAuthComponents.auth_form
      for={@form}
      id="resend_confirmation_form"
      phx-submit="send_instructions"
    >
      <UserAuthComponents.form_section variant="center">
        <UserAuthComponents.input_with_label field={@form[:email]} id="email" type="email" label_text="メールアドレス" required/>

        <UserAuthComponents.button variant="mt-sm">確認メールを送信</UserAuthComponents.button>

        <UserAuthComponents.link_button href={~p"/users/log_in"}>戻る</UserAuthComponents.link_button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_instructions", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email, including_not_confirmed: true) do
      Accounts.deliver_user_confirmation_instructions(
        user,
        &url(~p"/users/confirm/#{&1}")
      )
    end

    {:noreply,
     socket
     |> put_flash(:info, "確認メールを再度送信しました")
     |> redirect(to: ~p"/users/log_in")}
  end
end
