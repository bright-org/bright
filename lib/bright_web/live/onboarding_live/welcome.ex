defmodule BrightWeb.OnboardingLive.Welcome do
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="w-screen bg-white p-8 min-h-[720px] rounded-lg">
      <div class="flex place-content-center lg:place-content-start mb-12">
          <img src={~p"/images/logo_bright.svg"} width="256" />
      </div>

      <h1 class="font-bold text-3xl my-8">
        Brightへようこそ
      </h1>
      <h1 class="text-xl my-4">
        Brightはエンジニアのスキルを見える化するためのサービスです
      </h1>
      <h1 class="text-xl my-4">
        エンジニアだけでなく、インフラやデザイナー、マーケッターなど幅広い分野から
      </h1>
      <h1 class="text-xl mt-4 mb-12">
        自分に合ったスキルパネルを選び、ご自身のスキルを把握し、スキルアップにつなげていきましょう
      </h1>

      <div class="flex justify-center lg:justify-start w-full">
      <.link
        class="h-12 text-white bg-brightGreen-300 p-2 rounded-md text-lg lg:text-xl font-bold hover:opacity-70"
        navigate={~p"/onboardings"}
      >
        自分に合ったスキルパネルを見つける
      </.link>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, :page_title, "ようこそ")}
  end
end
