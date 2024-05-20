defmodule BrightWeb.UserSendResetPasswordUrlLive do
  use BrightWeb, :live_view
  alias BrightWeb.UserAuthComponents

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <UserAuthComponents.header>リンクを送信しました</UserAuthComponents.header>

    <UserAuthComponents.description>
      登録しているメールアドレスにパスワード再設定用のリンクを送信しました。<br />メールをご確認いただき、リンクを開いてください。
    </UserAuthComponents.description>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
