defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Gem Components
  """
  use Phoenix.Component

  @doc """
  Renders a Profile

  ## Examples
      <.profile/>
  """
  def profile(assigns) do
    ~H"""
    <div class="w-[682px]">
      <div class="flex">
        <div
          class="bg-test bg-contain h-20 w-20 mr-5"
          style="
            background-image: url('/images/sample/sample-image.png');
          "
        >
        </div>
        <div class="flex-1">
          <div class="flex justify-between pb-2 items-end">
            <div class="text-2xl font-bold">piacere</div>
            <div class="flex gap-x-3">
              <button
                type="button"
                class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
              >
                <span class="material-icons md-18 mr-1 text-brightGray-200">share</span> 優秀なエンジニア紹介
              </button>

              <button
                type="button"
                class="text-gray-900 bg-white px-2 py-1 inline-flex font-medium rounded-md text-sm items-center border border-brightGray-200"
              >
                <span class="material-icons md-18 mr-1 text-brightGray-200">star</span> 気になる
              </button>
            </div>
          </div>
          <div class="flex justify-between pt-3 border-brightGray-100 border-t">
            <div class="text-2xl">リードプログラマー</div>
            <div class="flex gap-x-6 mr-2">
              <button type="button">
                <img src="/images/common/twitter.svg" width="26px" />
              </button>
              <button type="button">
                <img src="/images/common/github.svg" width="26px" />
              </button>
              <button type="button">
                <img src="/images/common/facebook.svg" width="26px" />
              </button>
            </div>
          </div>
        </div>
      </div>
      <div class="pt-5">
        高校・大学と野球部に入っていました。チームで開発を行うような仕事が得意です。メインで使っている言語はJavaで中規模～大規模のシステム開発を受け持っています。最近Elixirを学び始め、Elixirで仕事ができると嬉しいです。
      </div>
    </div>
    """
  end

  @doc """
  Renders a Profile small

  ## Examples
      <.profile_snall/>
  """
  def profile_small(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2">
      <a class="inline-flex items-center gap-x-6">
        <img
          class="inline-block h-10 w-10 rounded-full"
          src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
        />
        <div>
          <p>nokichi</p>
          <p class="text-brightGray-300">アプリエンジニア</p>
        </div>
      </a>
    </li>
    """
  end
end
