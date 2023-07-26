defmodule BrightWeb.UserMenuComponents do
  @moduledoc """
  Bright Button Components
  """
  use BrightWeb, :live_component

  @doc """
  Renders a User Button

  ## Examples

      <.user_button icon_file_path="/images/sample/sample-image.png" />
  """
  attr :icon_file_path, :string

  def user_button(assigns) do
    ~H"""
    <button id="personal_settings_icon" class="hover:opacity-70">
      <.link patch={~p"/mypage/settings/general"}>
      <img
        class="inline-block h-10 w-10 rounded-full"
        src={@icon_file_path}
      />
      </.link>
    </button>
    """
  end

  defp user_menu(assigns) do
    menu_items = [
      %{text: "個人設定", href: "/settings/general", method: "get"},
      %{text: "ログアウトする", href: "/users/log_out", method: "delete"}
    ]

    assigns =
      assigns
      |> assign(:menu_items, menu_items)

    ~H"""
    <section class="hidden absolute bg-white min-h-[600px] p-4 right-0 shadow text-sm top-[60px] w-[800px] z-20" id="personal_settings">

    </section>
    <div
      id="user_menu"
      class="z-10 hidden bg-white divide-y divide-gray-100 rounded-lg shadow w-44 dark:bg-gray-700"
    >
      <ul class="py-2 text-sm text-gray-700 dark:text-gray-200" aria-labelledby="user_menu_dropmenu">
        <%= for menu_item <- @menu_items do %>
          <.user_menu_item menu_item={menu_item}/>
        <% end %>
      </ul>
    </div>
    """
  end

  attr :menu_item, :map

  defp user_menu_item(assigns) do
    ~H"""
        <li>

        <.link
        href={@menu_item.href}
        method={@menu_item.method}
        class="block px-4 py-2 hover:bg-gray-100 dark:hover:bg-gray-600 dark:hover:text-white"
        >
        <%= @menu_item.text %>
      </.link>

        </li>
    """
  end
end
