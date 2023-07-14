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

  attr :card, :map

  def contact_card(assigns) do
    ~H"""
    <div>
      <h5>重量な連絡</h5>
      <.tab id="contact_card" tabs={["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]} selected_tab={@card.selected_tab}>
        <ul class="flex gap-y-2.5 flex-col">
          <%= for notification <- @card.notifications do %>
            <.contact_card_row notification={notification} />
          <% end %>
        </ul>
      </.tab>
    </div>
    """
  end

  attr :notification, :map, required: true

  def contact_card_row(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.notification.inserted_at, "Etc/UTC")
    highlight_minutes = 60 * 60 * 8

    minutes =
      (DateTime.diff(DateTime.utc_now(), inserted_at) / 60)
      |> trunc()

    time_text = if minutes < 60, do: "#{minutes}分前", else: "#{trunc(minutes / 60)}時間前"

    style = highlight(minutes < highlight_minutes) <> " font-bold pl-4 inline-block"

    assigns =
      assigns
      |> assign(:style, style)
      |> assign(:time_text, time_text)

    ~H"""
    <li class="text-left flex items-center text-base">
      <span class="material-icons !text-lg text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <span class={@style}><%= @time_text %></span>
    </li>
    """
  end

  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"
end
