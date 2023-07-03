defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
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
end
