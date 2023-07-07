defmodule BrightWeb.OnboardingComponents do
  @moduledoc """
  Onboarding Components
  """
  use Phoenix.Component

  def card_career(assigns) do
    ~H"""
    <li class="bg-white px-4 py-4 rounded select-none w-72 hover:opacity-50">
      <a href="/onboardings/select_skill_panel" class="block">
        <b class="block text-center">Webアプリを作りたい</b>
        <div class="flex flex-wrap gap-2 justify-center mt-2 py-2">
          <span class="bg-enginner-dark px-2 py-0.5 rounded-full text-white text-xs">
            エンジニア
          </span>
          <span class="bg-infra-dark px-2 py-0.5 rounded-full text-white text-xs">
            インフラ
          </span>
          <span class="bg-designer-dark px-2 py-0.5 rounded-full text-white text-xs">
            デザイナー
          </span>
        </div>
      </a>
    </li>
    """
  end
end
