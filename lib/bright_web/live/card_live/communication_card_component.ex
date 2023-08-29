# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.CommunicationCardComponent do
  @moduledoc """
  Communication Card Component
  """
  use BrightWeb, :live_component
  import BrightWeb.TabComponents
  import BrightWeb.CardLive.CardListComponents
  # alias Bright.Notifications

  @tabs [
    {"skill_up", "スキルアップ"},
    {"blessed", "祝福された"},
    {"1on1_invitation", "1on1のお誘い"},
    {"promotion", "推し活"},
    {"intriguing", "気になる"},
    {"official_team", "運営公式"}
  ]

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.tab
        id="communication_card"
        tabs={@tabs}
        selected_tab={@card.selected_tab}
        page={@card.page_params.page}
        total_pages={@card.total_pages}
        target={@myself}
      >
        <div class="pt-4 px-6 min-h-[216px]">
        <% # TODO α版対応 :if={false"}を外すこと %>
          <ul :if={false} class="flex gap-y-2.5 flex-col">
            <li :if={Enum.count(@card.notifications) == 0} class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2" >
              <%= Enum.into(@tabs, %{}) |> Map.get(@card.selected_tab) %>はまだありません
              </div>
            </li>
            <%= for notification <- @card.notifications do %>
              <.card_row type={@card.selected_tab} notification={notification} />
            <% end %>
          </ul>

          <% # TODO ↓α版対応 %>
          <ul class="flex gap-y-2.5 flex-col">
            <li class="flex">
              <div class="text-left flex items-center text-base px-1 py-1 flex-1 mr-2">
                βリリース（10月予定）で利用可能になります
              </div>
            </li>
          </ul>
          <% # TODO ↑α版対応 %>

        </div>
      </.tab>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> assign(:tabs, @tabs)
      |> assign(:card, create_card_param("official_team"))
      |> assign_card()
    }
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => "communication_card", "tab_name" => tab_name},
        socket
      ) do
    card = create_card_param(tab_name)

    socket
    |> assign(:card, card)
    |> assign_card()
    |> then(&{:noreply, &1})
  end

  def handle_event(
        "previous_button_click",
        %{"id" => "communication_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page
    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => "communication_card"},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  defp card_view(socket, tab_name, page) do
    card = create_card_param(tab_name, page)

    socket
    |> assign(:card, card)
    |> assign_card()
    |> then(&{:noreply, &1})
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      notifications: [],
      page_params: %{page: page, page_size: 5},
      total_pages: 0
    }
  end

  # TODO α版以降対応
  # defp assign_card(%{assigns: %{current_user: user, card: card}} = socket) do
  #   notifications =
  #     Notifications.list_notification_by_type(
  #       user.id,
  #       card.selected_tab,
  #       card.page_params
  #     )

  #   card = %{card | notifications: notifications, total_pages: notifications.total_pages}

  #   socket
  #   |> assign(:card, card)
  # end

  # TODO α版対応
  defp assign_card(%{assigns: %{card: card}} = socket) do
    card = %{card | notifications: [], total_pages: 0}

    socket
    |> assign(:card, card)
  end
end
