defmodule BrightWeb.UserFinishResetPasswordLive do
  use BrightWeb, :live_view
  alias BrightWeb.UserAuthComponents

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <UserAuthComponents.header>パスワードリセットしました</UserAuthComponents.header>

    <UserAuthComponents.description>パスワードのリセットは成功しました。</UserAuthComponents.description>

    <UserAuthComponents.link_text href={~p"/users/log_in"}>ログインページへ</UserAuthComponents.link_text>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
