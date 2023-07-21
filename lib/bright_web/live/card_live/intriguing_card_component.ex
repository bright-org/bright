# TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新
defmodule BrightWeb.CardLive.IntriguingCardComponent do
  @moduledoc """
  Intriguing Card Components
  """
  use BrightWeb, :live_component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  @tabs ["気になる人", "チーム", "採用候補者"]
  @menu_items [%{text: "カスタムグループを作る", href: "/"}, %{text: "カスタムグループの編集", href: "/"}]
  @sample [
    %{
      user_name: "nokichi",
      title: "アプリエンジニア",
      icon_file_path:
        "https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
    },
    %{
      user_name: "user2",
      title: "ほげほげ",
      icon_file_path:
        "https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
    }
  ]

  @impl true
  def render(assigns) do
    assigns =
      assigns
      |> assign(:menu_items, @menu_items)
      |> assign(:tabs, @tabs)
      |> assign(:user_profiles, @sample)

    ~H"""
    <div>
      <.tab id="tab-single-default" tabs={@tabs} inner_tab={true} previous_enable menu_items={@menu_items}>
        <div class="pt-3 pb-1 px-6">
          <ul class="flex flex-wrap gap-y-1">
            <%= for user_profile <- @user_profiles do %>
              <.profile_small user_name={user_profile.user_name} title={user_profile.title} icon_file_path={user_profile.icon_file_path} />
            <% end %>
          </ul>
        </div>
      </.tab>
    </div>
    """
  end
end
