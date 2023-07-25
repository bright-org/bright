defmodule BrightWeb.UserTwoFactorAuthLive do
  use BrightWeb, :live_view
  alias BrightWeb.UserAuthComponents
  alias Bright.Accounts

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <UserAuthComponents.header>2段階認証</UserAuthComponents.header>

    <UserAuthComponents.description>
    メールに届いた認証コードを入力し「次へ進む」を押してください。<br><UserAuthComponents.link_block_text href="#" phx-click="resend_two_factor_auth_code">再送信する</UserAuthComponents.link_block_text>
    </UserAuthComponents.description>

    <UserAuthComponents.auth_form
      for={@form}
      id="two_factor_auth_code"
      method="post"
      action={~p"/users/two_factor_auth"}
    >
      <UserAuthComponents.form_section variant="center">
        <UserAuthComponents.input_with_label field={@form[:code]} id="code" type="number" label_text="認証用コード" required/>
        <.input field={@form[:token]} type="hidden" id="hidden_token" value={@token}/>

        <UserAuthComponents.button variant="mt-sm">次に進む</UserAuthComponents.button>

        <UserAuthComponents.link_button href={~p"/users/log_in"}>戻る</UserAuthComponents.link_button>
      </UserAuthComponents.form_section>
    </UserAuthComponents.auth_form>
    """
  end

  def mount(%{"token" => token} = _params, _session, socket) do
    if user = Accounts.get_user_by_2fa_auth_session_token(token) do
      {:ok, assign(socket, user: user, token: token, form: to_form(%{}, as: "user_2fa_code"))}
    else
      {:ok,
       socket
       |> put_flash(:error, "セッションの期限が切れました。再度ログインしてください。")
       |> redirect(to: ~p"/users/log_in")}
    end
  end

  def handle_event("resend_two_factor_auth_code", _params, %{assigns: %{user: user}} = socket) do
    token = Accounts.setup_user_2fa_auth(user)

    {:noreply,
     socket
     |> put_flash(:info, "確認メールを再送しました。")
     |> redirect(to: ~p"/users/two_factor_auth/#{token}")}
  end
end
