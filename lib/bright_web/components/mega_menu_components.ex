defmodule BrightWeb.MegaMenuComponents do
  @moduledoc """
  メガメニューの表示コンポーネント
  """

  @doc """
  Renders a MegaMenu Button

  以下のattrを指定可能

  - id 画面内でメガメニューボタンを一意に識別できるID
  - card_component 　一覧表示に使用するカードコンポーネント
  - label ボタンに表示する名称
  - display_user  カードの取得に使用するユーザー
  - dropdown_offset_skidding ドロップダウンの描画オフセット(labelの文字数に応じて調整する必要がある)
  - card_component liveComponentによるカード実装
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.mega_menu_button
      id="mega_menu_team"
      label="ボタンに表示する文言"
      dropdown_offset_skidding="307"
    />
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :dropdown_offset_skidding, :string, required: true
  slot :inner_block

  def mega_menu_button(assigns) do
    ~H"""
    <div
      id={"dropdown-#{@id}"}
      phx-hook="Dropdown"
      data-dropdown-offset-skidding={@dropdown_offset_skidding}
      data-dropdown-placement="bottom"
    >
      <button
        class="dropdownTrigger text-white bg-brightGreen-300 rounded-sm py-1.5 pl-3 flex items-center font-bold"
        type="button"
      >
        <span class="min-w-[6em]">
          <%= @label %>
        </span>
        <span
          class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
          expand_more
        </span>
      </button>

      <div
        class="dropdownTarget z-10 hidden bg-white rounded-sm shadow w-[750px]"
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
