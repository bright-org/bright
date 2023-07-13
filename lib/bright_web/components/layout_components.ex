defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component

  @doc """
  Renders a User Header

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新

  ## Examples
      <.user_header />
  """
  def user_header(assigns) do
    ~H"""
    <div class="w-full flex justify-between py-2.5 px-10 border-brightGray-100 border-b bg-white">
      <h4>マイページ</h4>
      <div class="flex gap-x-5">
        <.user_button1 />
        <.user_button2 />
        <.user_button3 />
        <.user_button4 />
      </div>
    </div>
    """
  end

  def user_button1(assigns) do
    ~H"""
    <button type="button"
      class="text-white bg-brightGreen-300 px-4 inline-flex rounded-md text-sm items-center font-bold h-9 hover:opacity-70">
      <span
          class="bg-white material-icons mr-1 !text-base !text-brightGreen-300 rounded-full h-6 w-6 !font-bold material-icons-outlined">sms</span>
      カスタマーサクセスに連絡
    </button>
    """
  end

  def user_button2(assigns) do
    ~H"""
    <button type="button"
      class="text-white bg-brightGreen-300 px-4 inline-flex rounded-md text-sm items-center font-bold h-9 hover:opacity-70">
      <span
          class="bg-white material-icons mr-1 !text-base !text-brightGreen-300 rounded-full h-6 w-6 !font-bold">search</span>
      スキル保有者を検索
    </button>
    """
  end

  def user_button3(assigns) do
    ~H"""
    <button type="button"
      class="text-black bg-brightGray-50 hover:bg-brightGray-100 rounded-full w-10 h-10 inline-flex items-center justify-center relative">
      <span class="material-icons">notifications_none</span>
      <div
          class="absolute inline-flex items-center justify-center w-5 h-5 text-xs font-bold text-white bg-attention-600 rounded-full -top-0 -right-2">
          1
      </div>
    </button>
    """
  end

  def user_button4(assigns) do
    ~H"""
    <button class="hover:opacity-70">
      <img class="inline-block h-10 w-10 rounded-full"
          src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80" />
    </button>
    """
  end

  @doc """
  Renders a Side Menu

  ## Examples
      <.side_menu />
  """
  def side_menu(assigns) do
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
