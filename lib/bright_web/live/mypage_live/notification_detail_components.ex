defmodule BrightWeb.MypageLive.NotificationDetailComponents do
  @moduledoc """
  Notification Detail Components
  """
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.header> <%= @notification.messages %> </.header>
      <div class="flex justify-between items-center my-2 gap-x-4">
        <%= Phoenix.HTML.Format.text_to_html @notification.detail, attributes: [class: "break-all grow"] %>
      </div>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    notification = %{messages: "サンプルタイトル", detail: "サンプル内容あああああああああああああ"}

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:notification, notification)}
  end
end
