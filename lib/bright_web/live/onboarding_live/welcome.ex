defmodule BrightWeb.OnboardingLive.Welcome do
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="w-screen bg-white p-8 min-h-[720px] rounded-lg">
      <div class="flex place-content-center lg:place-content-start mb-12">
          <img src={~p"/images/logo_tagline_skill.svg"} width="256" />
      </div>

      <h1 class="font-bold text-3xl my-8">
        Brightへようこそ
      </h1>
      <h1 class="text-xl my-4">
        Brightは今と過去、そして未来のスキルから “あなたの輝き” を見える化します
      </h1>
      <h1 class="text-xl my-4">
        エンジニアやインフラ、デザイナー、マーケッターなど幅広い分野からスキルが選べます
      </h1>
      <h1 class="text-xl mt-4 mb-12">
        自分に合ったスキルパネルを選び、スキル入力することで、あなたの輝きを体験してください
      </h1>

      <div class="flex justify-center lg:justify-start w-full">
        <.link
          class="h-12 text-white bg-brightGreen-300 p-2 rounded-md text-lg lg:text-xl font-bold hover:opacity-70"
          navigate={~p"/onboardings?open=want_todo_panel"}
        >
          自分に合ったスキルパネルを見つける
        </.link>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "ようこそ")
    |> then(&{:ok, &1})
  end
end
