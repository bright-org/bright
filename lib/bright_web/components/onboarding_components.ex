defmodule BrightWeb.OnbordingComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  def select_career(assigns) do
    ~H"""
    <h2 class="bg-black text-white">やりたいことや興味・関心があることからスキルを選ぶ</h2>

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Webアプリを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">スマホアプリを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Webサイトを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">アプリやWebの広告をしたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">AIをやってみたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">クラウドインフラを構築したい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">とにかく即戦力ではじめたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">個人でアプリを開発したい</a>
    </button>
    <br />

    <h2 class="bg-black text-white">現在のジョブ、または、なりたいジョブからスキルを選ぶ</h2>

    <a href="/mypage" class="text-blue-700">採用担当、人事、営業の方はこちら（自分のスキルを登録しません）</a>
    """
  end

  def select_skill_panel(assigns) do
    ~H"""
    <h2>エンジニア向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Elixir</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Java</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">PHP</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Python</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Ruby</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">JavaScript</a>
    </button>
    <br />

    <h2>インフラ向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">SQL</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">DB</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">ネットワーク</a>
    </button>
    <br />

    <h2>デザイナー向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Webデザイン</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">HTML/CSS</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">Figma</a>
    </button>
    <br />

    <h2>マーケッター向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">GA4</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/select_skill_panel">SEO</a>
    </button>
    <br />

    <a href="/onboardings" class="text-blue-700">戻る</a>
    """
  end
end
