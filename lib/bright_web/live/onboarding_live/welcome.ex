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

      <div class="my-4">
        <div phx-click="toggre_is_terms_of_service_checked" class="mt-1">
          <input type="checkbox" id="terms_of_service" class="rounded" checked={@is_terms_of_service_checked?} />
          <label for="terms_of_service" class="pl-1 text-xs">
            <a href="https://bright-fun.org/terms/terms.pdf" class="text-link underline font-semibold" target="_blank">利用規約</a>に同意する
          </label>
        </div>

        <div phx-click="toggre_is_privacy_policy_checked" class="mt-1">
          <input type="checkbox" id="privacy_policy" class="rounded" checked={@is_privacy_policy_checked?} />
          <label for="privacy_policy" class="pl-1 text-xs">
            <a href="https://bright-fun.org/privacy/privacy.pdf" class="text-link underline font-semibold" target="_blank">プライバシーポリシー</a>に同意する
          </label>
        </div>

        <div phx-click="toggre_is_law_checked" class="mt-1">
          <input type="checkbox" id="law" class="rounded" checked={@is_law_checked?} />
          <label for="law" class="pl-1 text-xs">
            <a href="https://bright-fun.org/laws/laws.pdf" class="text-link underline font-semibold" target="_blank">法令に基づく表記</a>を確認した
          </label>
        </div>
      </div>

      <div class="flex justify-center lg:justify-start w-full">
      <button
        class="h-12 text-white bg-brightGreen-300 p-2 rounded-md text-lg lg:text-xl font-bold hover:opacity-70 disabled:bg-gray-400"
        disabled={!(@is_terms_of_service_checked? && @is_privacy_policy_checked? && @is_law_checked?)}
        phx-click={JS.navigate(~p"/onboardings?open=want_todo_panel")}
      >
        自分に合ったスキルパネルを見つける
      </button>
      </div>
    </section>
    """
  end

  def mount(_params, _session, socket) do
    socket
    |> assign(:page_title, "ようこそ")
    |> assign(is_terms_of_service_checked?: false)
    |> assign(is_privacy_policy_checked?: false)
    |> assign(is_law_checked?: false)
    |> then(&{:ok, &1})
  end

  def handle_event(
        "toggre_is_terms_of_service_checked",
        _params,
        %{assigns: %{is_terms_of_service_checked?: is_terms_of_service_checked?}} = socket
      ) do
    socket
    |> assign(is_terms_of_service_checked?: !is_terms_of_service_checked?)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "toggre_is_privacy_policy_checked",
        _params,
        %{assigns: %{is_privacy_policy_checked?: is_privacy_policy_checked?}} = socket
      ) do
    socket
    |> assign(is_privacy_policy_checked?: !is_privacy_policy_checked?)
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "toggre_is_law_checked",
        _params,
        %{assigns: %{is_law_checked?: is_law_checked?}} = socket
      ) do
    socket
    |> assign(is_law_checked?: !is_law_checked?)
    |> then(&{:noreply, &1})
  end
end
