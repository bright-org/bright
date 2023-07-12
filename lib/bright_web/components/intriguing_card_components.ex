defmodule BrightWeb.IntriguingCardComponents do
  @moduledoc """
  Intriguing Card Components
  """
  use Phoenix.Component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新

  @doc """
  Renders a Intriguing Card

  ## Examples
      <.intriguing_card />
  """
  def intriguing_card(assigns) do
    menu_items = [
      %{text: "カスタムグループを作る", href: "/"},
      %{text: "カスタムグループの編集", href: "/"},
      %{text: "カスタムグループの削除", href: "/"}
    ]

    assigns =
      assigns
      |> assign(:menu_items, menu_items)

    ~H"""
    <div>
      <h5>関わっているユーザー</h5>
      <.tab id="tab-single-default" tabs={["気になる人", "チーム", "採用候補者"]} inner_tab={true} previous_enable menu_items={@menu_items}>
        <.intriguing_card_body />
      </.tab>
    </div>
    """
  end

  @spec intriguing_card_body(any) :: Phoenix.LiveView.Rendered.t()
  def intriguing_card_body(assigns) do
    ~H"""
    <div class="pt-3 pb-1 px-6">
     <ul class="flex flex-wrap gap-y-1">
     <%= for _ <- 1..5 do %>
     <.profile_small />
      <% end %>
    </ul>
    </div>
    """
  end

end
