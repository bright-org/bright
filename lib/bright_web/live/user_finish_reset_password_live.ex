defmodule BrightWeb.UserFinishResetPasswordLive do
  use BrightWeb, :live_view

  def render(%{live_action: :show} = assigns) do
    ~H"""
      <h1 class="font-bold text-center text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">パスワードリセットしました</span>
      </h1>

      <p class="mt-8 mx-auto text-sm w-fit">パスワードのリセットは成功しました。</p>

      <p class="mt-8 text-link text-center text-xs"><.link navigate={~p"/users/log_in"} class="underline">ログインページへ</.link></p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
