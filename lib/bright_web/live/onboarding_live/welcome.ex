defmodule BrightWeb.OnboardingLive.Welcome do
  use BrightWeb, :live_view

  def render(assigns) do
    ~H"""
    <section class="bg-white p-8 min-h-[720px] max-w-[1300px] rounded-lg">
      <div class="flex place-content-center mb-12">
          <img src={~p"/images/logo_bright.svg"} width="256" />
      </div>

      <h1 class="font-bold text-3xl my-8">
        Brightへようこそ
      </h1>
      <h1 class=" text-xl my-4">
        Brightはエンジニアのスキルを見える化するためのサービスです
      </h1>
      <h1 class=" text-xl my-4">
        エンジニアだけでなく、インフラやデザイナー、マーケッターなど幅広い分野から
      </h1>
      <h1 class=" text-xl mt-4 mb-12">
        自分に合ったスキルパネルを選び、ご自身のスキルを把握し、スキルアップにつなげていきましょう
      </h1>
      <.link
        class="h-9 text-white bg-brightGreen-300 p-2 mt-16 rounded-md text-sm  font-bold hover:opacity-70"
        navigate={~p"/onboardings"}
      >
        自分に合ったスキルパネルを見つける
      </.link>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
