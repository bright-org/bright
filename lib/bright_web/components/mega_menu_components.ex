defmodule BrightWeb.MegaMenuComponents do
  @moduledoc """
  メガメニューの表示コンポーネント
  """

  @doc """
  Renders a MegaMenu Button

  以下のattrを指定可能

  - id 画面内でメガメニューボタンを一意に識別できるID
  - label ボタンに表示する名称
  - dropdown_offset_skidding ドロップダウンの描画オフセット(labelの文字数に応じて調整する必要がある)
  - menu_width ドロップダウンメニューの幅指定（デフォルトは750px）

  ## Examples
    <.mega_menu_button
      id="mega_menu_team"
      dropdown_offset_skidding="307"
      menu_width="w-[750px]"
    >
      <:button_content>
        表示対象者を切替
      </:button_content>
      <div>メガメニューの中身</div>
    </.mega_menu_button>
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :dropdown_offset_skidding, :string, required: true
  attr :menu_width, :string, required: false, default: "lg:w-[750px]"
  slot :button_content, required: true
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
        class="dropdownTrigger text-white bg-brightGreen-300 rounded-md py-1.5 pl-3 flex items-center font-bold hover:filter hover:brightness-95"
        type="button"
      >
        <span class="inline-flex gap-x-2 min-w-[4em] lg:min-w-[6em]">
          <%= render_slot(@button_content) %>
        </span>
        <span
          class="material-icons relative ml-2 px-1 before:content[''] before:absolute before:left-0 before:top-[-8px] before:bg-brightGray-50 before:w-[1px] before:h-[42px]">
          expand_more
        </span>
      </button>

      <div
        class={["dropdownTarget z-30 hidden bg-white rounded-md shadow static w-full", @menu_width]}
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
