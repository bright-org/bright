defmodule BrightWeb.MenuComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component

  @doc """
  Renders a Menu

  ## Examples
      <.menu/>
  """
  def menu(assigns) do
    ~H"""
    <aside class="flex bg-brightGray-900 min-h-screen flex-col w-[200px] pt-6 pl-3">
      <img src="/images/common/logo.svg" } width="163px" />
      <ul class="grid gap-y-10 pl-5 pt-6">
        <li>
          <a class="!text-white text-base" href="/mypage">マイページ</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">キャリアパス</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">スキルアップ</a>
        </li>
        <li>
          <a class="!text-white text-base" href="/mypage">チームスキル分析</a>
        </li>
      </ul>
    </aside>
    """
  end
end
