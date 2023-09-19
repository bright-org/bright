defmodule BrightWeb.BrightModalComponents do
  @moduledoc """
  CoreComponentsからmodal関連のコピー実装
  スタイルの設定を変更および上書き設定可能なattrを追加
  """
  use Phoenix.Component
  import BrightWeb.CoreComponents, only: [hide_modal: 1, icon: 1, show: 2]

  alias Phoenix.LiveView.JS
  import BrightWeb.Gettext

  @doc """
  Renders a modal.

  CoreComponents.modal/1のコピー実装

  デフォルト指定の場合のスタイルをBrightデザインに合わせつつ、以下のattrを追加してデザインを指定できるよう機能拡張

  - style_of_modal_flame_out モーダルフレーム外のスタイル
  - style_of_modal_flame モーダル枠全体のスタイル
  - enable_cancel_button 閉じるボタン(X)を表示するか否か
  - cancel_button_confirm 閉じるボタン(X)時のdata-confirm表示内容. 未指定(nil)で非表示
  - style_of_cancel_button_rayout 閉じるボタン(X)を囲むdevのスタイル
  - style_of_cancel_button 閉じるボタン(X)のスタイル
  - style_of_cancel_button_x_mark 閉じるボタン(X)のXマークのスタイル

  ## Examples

      <.bright_modal id="confirm-modal">
        This is a modal.
      </.bright_modal>

  JS commands may be passed to the `:on_cancel` to configure
  the closing/cancel event, for example:

      <.bright_modal id="confirm"
        on_cancel={JS.navigate(~p"/posts")}
        style_of_modal_flame_out="p-4 sm:p-6 lg:py-8"
        style_of_modal_flame=
        enable_cancel_button={true}
        style_of_cancel_button_rayout="absolute top-6 right-5"
        style_of_cancel_button="-m-3 flex-none p-3 opacity-80"
        style_of_cancel_button_x_mark="h-10 w-10"
      >
        This is another modal.
      </.bright_modal>

  """

  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :style_of_modal_flame_out, :string, default: "p-4 sm:p-6 lg:py-8"

  attr :style_of_modal_flame, :string,
    default:
      "shadow-zinc-700/10 ring-zinc-700/10 relative hidden rounded-md bg-white p-14 shadow-lg ring-1 transition"

  attr :enable_cancel_button, :boolean, default: true
  attr :cancel_button_confirm, :string, default: nil
  attr :style_of_cancel_button_rayout, :string, default: "absolute top-6 right-5"
  attr :style_of_cancel_button, :string, default: "-m-3 flex-none p-3 opacity-80"
  attr :style_of_cancel_button_x_mark, :string, default: "h-8 w-8"
  attr :on_cancel, JS, default: %JS{}
  slot :inner_block, required: true

  def bright_modal(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && show_bright_modal(@id)}
      phx-remove={hide_modal(@id)}
      data-cancel={JS.exec(@on_cancel, "phx-remove")}
      class="relative z-50 hidden"
    >
      <div id={"#{@id}-bg"} class="bg-zinc-50/90 fixed inset-0 transition-opacity" aria-hidden="true" />
      <div
        class="fixed inset-0 overflow-y-auto"
        aria-labelledby={"#{@id}-title"}
        aria-describedby={"#{@id}-description"}
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <div class="flex min-h-full items-center justify-center">
          <div class={@style_of_modal_flame_out}>
            <.focus_wrap
              id={"#{@id}-container"}
              class={@style_of_modal_flame}
            >
            <%= if @enable_cancel_button do %>
              <div class={@style_of_cancel_button_rayout} >
                <button
                  phx-click={JS.exec("data-cancel", to: "##{@id}")}
                  type="button"
                  class={@style_of_cancel_button}
                  data-confirm={@cancel_button_confirm}
                  aria-label={gettext("close")}
                >
                  <.icon name="hero-x-mark-solid" class={@style_of_cancel_button_x_mark} />
                </button>
              </div>
            <% end %>
              <div id={"#{@id}-content"}>
                <%= render_slot(@inner_block) %>
              </div>
            </.focus_wrap>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  CoreComponents.show_modal/1のコピー実装

  transitionのスタイルにモーダル全体の枠にスタイルがハードコードされておりモーダル幅が画面1/3固定されるので実装
  関数名がshow_modalのままだとCorecomponentsもimportしている実装で関数名の競合がおこるので名称を変更
  """
  def show_bright_modal(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.show(to: "##{id}")
    |> JS.show(
      to: "##{id}-bg",
      transition: {"transition-all transform ease-out duration-300", "opacity-0", "opacity-100"}
    )
    |> show("##{id}-container")
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end
end
