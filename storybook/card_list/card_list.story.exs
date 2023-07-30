defmodule Storybook.Card_list.CardListComponents do
  use PhoenixStorybook.Story, :example
  import BrightWeb.CardLive.CardListComponents

  @hour 60
  @day @hour * 24

  def doc do
    "CardListComponents Example"
  end

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:notifications, create_notifications())

    ~H"""
    <h5>contact card_row</h5>
    <br>
    <ul class="flex gap-y-2.5 flex-col">
      <%= for notification <- @notifications do %>
        <.card_row type="contact" notification={notification} />
      <% end %>
    </ul>
    <br>
    <hr>
    <h5>communication card_row</h5>
    <br>
    <ul class="flex gap-y-2.5 flex-col">
      <%= for notification <- @notifications do %>
        <.card_row type="communication" notification={notification} />
      <% end %>
    </ul>
    """
  end

  def create_notifications() do
    now = DateTime.utc_now()

    [1, 59, @hour, 8 * @hour - 1, 8 * @hour, @day - 1, @day, 2 * @day]
    |> Enum.map(&create_notification(DateTime.add(now, -&1 * 60)))
  end

  def create_notification(inserted_at),
    do: %{icon_type: "person", message: "メッセージの中身", inserted_at: inserted_at}
end
