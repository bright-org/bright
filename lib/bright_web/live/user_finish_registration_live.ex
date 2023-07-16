defmodule BrightWeb.UserFinishRegistrationLive do
  use BrightWeb, :live_view

  def render(%{live_action: :show} = assigns) do
    ~H"""
      <h1 class="font-bold text-center text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">仮登録完了</span>
      </h1>

      <p class="mt-8 mx-auto text-sm w-fit">仮登録完了メールを送信しましたので<br>メールの内容に従って本登録の手続き<br>を進めてください。</p>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
