defmodule BrightWeb.SubscriptionLive.Activate do
  use BrightWeb, :live_view

  alias Bright.Subscriptions

  require Logger

  def mount(%{"session_id" => session_id}, _session, socket) do
    if connected?(socket), do: send(self(), {:process_session, session_id})

    {:ok,
     socket
     |> assign(:loading, true)
     |> assign(:page_title, "契約処理中")}
  end

  def mount(params, _session, socket) do
    {:ok, socket |> redirect(to: ~p"/mypage")}
  end

  def handle_info({:process_session, session_id}, socket) do
    Logger.info("############ PROCESS SESSION #{inspect(session_id)}")

    case Subscriptions.start_subscription(session_id) do
      :ok ->
        {:noreply,
         socket
         |> assign(:page_title, "契約完了")
         |> assign(:loading, false)
         |> assign(:success, true)}

        # TODO: DBへのインサート失敗などの場合、契約失敗として表示した方が良いので、そのように修正する
      {:error, reason} ->
        {:noreply, socket |> redirect(to: ~p"/mypage")}

        # すでに契約処理がWebhookなどで完了している場合などは特に失敗として表示せず、マイページに着地させる
      _ ->
        {:noreply, socket |> redirect(to: ~p"/mypage")}
    end
  end
end
