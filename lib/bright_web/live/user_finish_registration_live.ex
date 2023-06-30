defmodule BrightWeb.UserFinishRegistrationLive do
  use BrightWeb, :live_view

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">登録完了</.header>

      <p class="text-center mt-4">
        登録確認メールを送信しますのでご確認ください
      </p>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
