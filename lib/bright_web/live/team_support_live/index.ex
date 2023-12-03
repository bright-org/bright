defmodule BrightWeb.TeamSupportLive.Index do
  @moduledoc """
  採用・育成支援一覧画面
  """
  use BrightWeb, :live_view

  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]
  import BrightWeb.TeamComponents

  alias BrightWeb.CardLive.CardListComponents

  alias Bright.UserProfiles
  alias Bright.Teams

  @tabs [
    {"requesting", "支援依頼承認待ち"},
    {"supporting", "支援中"}
  ]

  @list_contailnet_page_size 10

  def mount(params, _session, socket) do
    tabs = @tabs
    first_tab = tabs |> Enum.at(0) |> elem(0)

    {:ok,
     socket
     |> assign(:page_title, "採用・育成支援一覧")
     |> assign(:shown_hr_support_modal, false)
     |> assign(:hr_support_modal_mode, nil)
     |> assign(:display_team_supporter_team, nil)
     |> assign(:tabs, @tabs)
     |> assign(:card, create_card_param(first_tab))
     |> assign_card(first_tab)}
  end

  @impl true
  def handle_event(
        "tab_click",
        %{"id" => _id, "tab_name" => tab_name},
        socket
      ) do
    card_view(socket, tab_name, 1)
  end

  def handle_event(
        "previous_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page - 1
    page = if page < 1, do: 1, else: page

    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "next_button_click",
        %{"id" => _id},
        %{assigns: %{card: card}} = socket
      ) do
    page = card.page_params.page + 1

    page =
      if page > card.total_pages,
        do: card.total_pages,
        else: page

    card_view(socket, card.selected_tab, page)
  end

  def handle_event(
        "show_hr_support_modal",
        %{
          "team_supporter_team_id" => team_supporter_team_id,
          "hr_support_modal_mode" => hr_support_modal_mode
        },
        socket
      ) do
    display_team_supporter_team =
      socket.assigns.card.entries
      |> Enum.find(fn team_supporter_team ->
        team_supporter_team.id == team_supporter_team_id
      end)

    {:noreply,
     socket
     |> assign(:display_team_supporter_team, display_team_supporter_team)
     |> assign(:shown_hr_support_modal, true)
     |> assign(:hr_support_modal_mode, hr_support_modal_mode)}
  end

  def handle_event("close_hr_support_modal", _values, socket) do
    {:noreply,
     socket
     |> assign(:shown_hr_support_modal, false)}
  end

  defp card_view(socket, tab_name, page) do
    card = create_card_param(tab_name, page)

    socket
    |> assign(:card, card)
    |> assign_card(tab_name)
    |> then(&{:noreply, &1})
  end

  defp create_card_param(selected_tab, page \\ 1) do
    %{
      selected_tab: selected_tab,
      entries: [],
      page_params: %{page: page, page_size: @list_contailnet_page_size},
      total_entries: 0,
      total_pages: 0
    }
  end

  defp assign_card(socket, "requesting") do
    page =
      Teams.list_support_request_by_supporter_user_id(
        socket.assigns.current_user.id,
        socket.assigns.card.page_params
      )

    card = %{
      socket.assigns.card
      | entries: page.entries,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end

  defp assign_card(socket, "supporting") do
    page =
      Teams.list_supporting_request_by_supporter_user_id(
        socket.assigns.current_user.id,
        socket.assigns.card.page_params
      )

    card = %{
      socket.assigns.card
      | entries: page.entries,
        total_entries: page.total_entries,
        total_pages: page.total_pages
    }

    socket
    |> assign(:card, card)
  end
end
