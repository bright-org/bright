defmodule BrightWeb.CommunicationCardComponents do
  @moduledoc """
  Communication Card Components
  """
  use Phoenix.Component
  import BrightWeb.TabComponents

  @highlight_minutes 60 * 8

  @doc """
  Renders a Communication Card

  ## Examples
      <.communication_card card={@card} />
  """

  attr :card, :map

  def communication_card(assigns) do
    ~H"""
    <div>
      <h5>さまざまな人たちとの交流</h5>
      <.tab id="communication_card" tabs={["スキルアップ", "1on1のお誘い", "所属チームから", "「気になる」された", "運勢公式チーム発足"]} selected_tab={@card.selected_tab}>
        <ul class="flex gap-y-2.5 flex-col">
          <%= for notification <- @card.notifications do %>
            <.communication_card_row notification={notification} />
          <% end %>
        </ul>
      </.tab>
    </div>
    """
  end

  attr :notification, :map, required: true

  def communication_card_row(assigns) do
    # TODO ↓contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること
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

    # TODO ↑contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること

    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 px-1">
      <span class="material-icons-outlined !text-sm !text-white bg-brightGreen-300 rounded-full !flex w-6 h-6 mr-2.5 !items-center !justify-center">
        <%= @notification.icon_type %>
      </span>
      <%= @notification.message %>
      <span class={@style}><%= @time_text %></span>
    </li>
    """
  end

  # TODO ↓contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること
  defp highlight(true), do: "text-brightGreen-300"
  defp highlight(false), do: "text-brightGray-300"

  # TODO ↑contact_card_rowのソースと同じ　他のカードと考えて最終的には共通をすること
end
