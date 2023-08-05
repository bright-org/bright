defmodule BrightWeb.MegaMenueComponents do
  @moduledoc """
  メガメニューの表示コンポーネント
  """

  @doc """
  Renders a MegaMenue botton

  以下のattrを指定可能

  - id 画面内でメガメニューボタンを一意に識別できるID
  - card_component 　一覧表示に使用するカードコンポーネント
  - label ボタンに表示する名称
  - current_user  カードの取得に使用するユーザー
  - dropdown_offset_skidding ドロップダウンの描画オフセット(labelの文字数に応じて調整する必要がある)
  - card_component liveComponentによるカード実装
  - over_ride_on_card_row_click_target カードコンポーネント内の行クリック時のハンドラを呼び出し元のハンドラで実装するか否か falseの場合、本実装デフォルトの挙動(チームIDのみ指定してのチームスキル分析への遷移)を実行する

  ## Examples
    <.mega_menue_botton
      id="mega_menue_team"
      label="ボタンに表示する文言"
      current_user={@current_user}
      dropdown_offset_skidding="307"
      card_component={BrightWeb.CardLive.RelatedTeamCardComponent}
      over_ride_on_card_row_click_target={:true}
    />
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :dropdown_offset_skidding, :string, required: true
  attr :current_user, Bright.Accounts.User, required: true
  attr :card_component, :any, required: true
  attr :over_ride_on_card_row_click_target, :boolean, required: false, default: false

  def mega_menue_botton(assigns) do

    ~H"""
    <button
      id="dropdownOffsetButton"
      data-dropdown-toggle="dropdownOffset"
      data-dropdown-offset-skidding={@dropdown_offset_skidding}
      data-dropdown-placement="bottom"
      class="text-white bg-brightGreen-300 rounded-sm py-1.5 pl-3 flex items-center font-bold"
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
    <!-- メガメニューの内容 -->
      <div
        id="dropdownOffset"
        class="z-10 hidden bg-white rounded-sm shadow w-[750px]"
      >
        <.live_component
          id={@id}
          module={@card_component}
          current_user={@current_user}
          over_ride_on_card_row_click_target={@over_ride_on_card_row_click_target}
        />
      </div>
    """
  end
end
