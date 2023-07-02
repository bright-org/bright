defmodule BrightWeb.OnbordingComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  def select_career(assigns) do
    ~H"""
    <h2 class="bg-black text-white">やりたいことや興味・関心があることからスキルを選ぶ</h2>

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Webアプリを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">スマホアプリを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Webサイトを作りたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">アプリやWebの広告をしたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">AIをやってみたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">クラウドインフラを構築したい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">とにかく即戦力ではじめたい</a>
    </button>
    <br />

    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">個人でアプリを開発したい</a>
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
      <a href="/onboardings/skillpanel">Elixir</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Java</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">PHP</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Python</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Ruby</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">JavaScript</a>
    </button>
    <br />

    <h2>インフラ向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">SQL</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">DB</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">ネットワーク</a>
    </button>
    <br />

    <h2>デザイナー向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Webデザイン</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">HTML/CSS</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">Figma</a>
    </button>
    <br />

    <h2>マーケッター向けのスキル</h2>
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">GA4</a>
    </button>
    <br />
    <button class="rounded-lg bg-orange-100 py-2 px-3 m-1 text-sm font-semibold leading-6">
      <a href="/onboardings/skillpanel">SEO</a>
    </button>
    <br />

    <a href="/onboardings" class="text-blue-700">戻る</a>
    """
  end
end
