# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.ContactCardComponent do
  @moduledoc """
  Contact Card Component
  """

  use BrightWeb, :live_component
  import BrightWeb.TabComponents

  @highlight_minutes 60 * 8

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h5>重量な連絡</h5>
      <.tab id="contact_card" tabs={["チーム招待", "デイリー", "ウイークリー", "採用の調整", "スキルパネル更新", "運営"]} selected_tab={@card.selected_tab} page={@card.page_params.page} total_pages={@card.total_pages}>
        <div class="pt-4 pb-1 px-8">
          <ul class="flex gap-y-2.5 flex-col">
            <%= for notification <- @card.notifications do %>
              <.contact_card_row notification={notification} />
            <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end

  def contact_card_row(assigns) do
    {:ok, inserted_at} = DateTime.from_naive(assigns.notification.inserted_at, "Etc/UTC")

    minutes =
      DateTime.diff(DateTime.utc_now(), inserted_at, :minute)
      |> trunc()

    time_text = if minutes < 60, do: "#{minutes}分前", else: "#{trunc(minutes / 60)}時間前"

    style = highlight(minutes < @highlight_minutes) <> " font-bold pl-4 inline-block"

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
