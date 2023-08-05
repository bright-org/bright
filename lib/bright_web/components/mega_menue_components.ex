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
  - low_on_click_target チームの表示をクリックした際に発火するon_team_card_row_clickイベントハンドラのターゲット。指定されない場合@myselfがデフォルト指定される為、大本のliveviewがターゲットとなる。

  ## Examples
    <.mega_menue_botton
      id="mega_menue_team"
      label="ボタンに表示する文言"
      current_user={@current_user}
      dropdown_offset_skidding="307"
      card_component={BrightWeb.CardLive.RelatedTeamCardComponent}
      low_on_click_target={@myself}
    />
  """

  use Phoenix.Component

  attr :id, :string, required: true
  attr :label, :string, required: true
  attr :dropdown_offset_skidding, :string, required: true
  attr :current_user, Bright.Accounts.User, required: true
  attr :card_component, :any, required: true
  attr :low_on_click_target, :any, required: false, default: @myself

  # style="position: absolute; inset: 0px auto auto 0px; margin: 0px; transform: translate(728px, 124px);"

  def mega_menue_botton(assigns) do
    IO.puts(assigns.dropdown_offset_skidding)

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
          low_on_click_target={@low_on_click_target}
        />
      </div>
    """
  end
end
