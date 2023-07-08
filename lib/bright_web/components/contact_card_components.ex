defmodule BrightWeb.ContactCardComponents do
  @moduledoc """
  Contact Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @doc """
  Renders a Contact

  ## Examples
      <.contact_card />
  """
  def contact_card(assigns) do
    ~H"""
    <div>
      <h5>重量な連絡</h5>
      <.tab tabs={["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]}>
        <.contact_card_body />
      </.tab>
    </div>
    """
  end

  def contact_card_body(assigns) do
    ~H"""
    <ul class="flex gap-y-2.5 flex-col">
      <%= for _i <- 1..5 do %>
        <.contact_card_row />
      <% end %>
    </ul>
    """
  end

  def contact_card_row(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base">
      <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        person
      </span>
      nakoさんからの紹介 / mikaさん / Web開発（Elixir）
      <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
    </li>
    """
  end
end
