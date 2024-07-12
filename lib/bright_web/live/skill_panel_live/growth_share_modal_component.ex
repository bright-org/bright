defmodule BrightWeb.SkillPanelLive.GrowthShareModalComponent do
  @moduledoc """
  成長をシェアする際に表示するモーダル
  """

  use BrightWeb, :live_component

  import BrightWeb.BrightModalComponents

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.bright_modal
        id={"#{@id}_modal"}
        :if={@open}
        show
      >
        <.header>ナイス ブライト！＜ここに良い見出し＞</.header>
        <div class="mt-4">
          2024年7月からの活動です。

          ああああのレベルを「平均」からスタートしました！

          ＜ここにシェアされる予定の画像 後のOG画像？＞
          ＜画像にしておくと特定のシェア以外にも使える＞

          ＜ここにシェアボタン＞
        </div>
      </.bright_modal>
    </div>
    """
  end

  def update(%{open: true} = _assigns, socket) do
    {:ok,
      socket
      |> assign(:open, true)}
  end

  def update(assigns, socket) do
    {:ok,
      socket
      |> assign(assigns)
      |> assign(:open, false)}
  end
end
