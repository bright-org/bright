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
  attr :datas, :list, default: []
  def contact_card(assigns) do
    assigns =
      assigns
      |> assign(:datas, dummy())

    ~H"""
    <div>
      <h5>重量な連絡</h5>
      <.tab tabs={["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]}>
        <.contact_card_body datas={@datas}/>
      </.tab>
    </div>
    """
  end

  attr :datas, :list, default: []
  def contact_card_body(assigns) do

    ~H"""
    <ul class="flex gap-y-2.5 flex-col">
      <%= for data <- assigns.datas do %>
        <.contact_card_row data={data}/>
      <% end %>
    </ul>
    """
  end

  attr :data, :map, required: true
  def contact_card_row(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base">
      <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= assigns.data.icon_type %>
      </span>
      <%= assigns.data.message %>
      <span class="text-brightGreen-300 font-bold pl-4 inline-block">1時間前</span>
    </li>
    """
  end

  defp dummy do
    [%{icon_type: "person", message: "nakoさんからの紹介 / mikaさん / Web開発（Elixir）"}]
  end
end
