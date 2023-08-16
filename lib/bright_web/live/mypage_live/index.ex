defmodule BrightWeb.MypageLive.Index do
  use BrightWeb, :live_view
  import BrightWeb.ProfileComponents
  # import BrightWeb.ChartComponents
  import BrightWeb.BrightModalComponents, only: [bright_modal: 1]

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign_display_user(params)
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
    |> assign(:mypage, nil)
  end

  # TODO: プロフィール読み込み共通化対象
  def assign_display_user(socket, %{"user_name" => user_name}) do
    # TODO: チームに所属のチェックを実装すること
    IO.inspect("-------------------------------指定------------------")
    IO.inspect(user_name)

    socket
    |> assign(:display_user, socket.assigns.current_user)
  end

  def assign_display_user(socket, %{"user_name_crypted" => user_name_crypted}) do
    IO.inspect("-------------------------------暗号化------------------")
    IO.inspect(user_name_crypted)

    socket
    |> assign(:display_user, socket.assigns.current_user)
  end

  def assign_display_user(socket, params) do
    IO.inspect("------------------------------自分自身------------------")
    IO.inspect(params)

    socket
    |> assign(:display_user, socket.assigns.current_user)
  end
end
