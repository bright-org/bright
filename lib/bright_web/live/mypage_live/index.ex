defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  # import BrightWeb.ChartComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]
  alias BrightWeb.DisplayUserHelper
  alias Bright.Subscriptions

  @impl true
  def mount(params, _session, socket) do
    socket
    |> DisplayUserHelper.assign_display_user(params)
    |> assign(:page_title, "マイページ")
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "マイページ")
    |> assign(:notification_detail, false)
    |> assign(:search, false)
  end

  defp apply_action(socket, :notification_detail, %{
         "notification_id" => notification_id,
         "notification_type" => notification_type
       }) do
    socket
    |> assign(:page_title, "マイページ")
    |> assign(:notification_detail, true)
    |> assign(:notification_id, notification_id)
    |> assign(:notification_type, notification_type)
    |> assign(:search, false)
  end

  defp apply_action(socket, :search, _params) do
    socket
    |> assign(:page_title, "スキル検索／スカウト")
    |> assign(:notification_detail, false)
    |> assign(:search, true)
  end
end
