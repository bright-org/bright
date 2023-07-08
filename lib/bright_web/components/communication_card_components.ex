defmodule BrightWeb.CommunicationCardComponents do
  @moduledoc """
  Communication Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @doc """
  Renders a Communication Card

  ## Examples
      <.communication_card/>
  """
  def communication_card(assigns) do
    ~H"""
    <div>
      <h5>さまざまな人たちとの交流</h5>
      <.tab tabs={["スキルアップ", "1on1のお誘い", "所属チームから", "「気になる」された", "運勢公式チーム発足"]}>
        <.communication_card_body />
      </.tab>
    </div>
    """
  end

  def communication_card_body(assigns) do
    ~H"""
    <ul class="flex gap-y-2.5 flex-col">
      <%= for _i <- 1..5 do %>
        <.communication_card_row />
      <% end %>
    </ul>
    """
  end

  def communication_card_row(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        pentagon
      </span>
      中道洋介さんがスキルアップしました <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
    </li>
    """
  end
end
