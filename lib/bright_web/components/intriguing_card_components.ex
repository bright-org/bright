defmodule BrightWeb.IntriguingCardComponents do
  @moduledoc """
  Intriguing Card Components
  """
  use Phoenix.Component
  import BrightWeb.ProfileComponents
  import BrightWeb.TabComponents

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までマイページのみ部品デザイン更新

  @doc """
  Renders a Intriguing Card

  ## Examples
      <.intriguing_card />
  """
  def intriguing_card(assigns) do
    menu_items = [
      %{text: "カスタムグループを作る", href: "/"},
      %{text: "カスタムグループの編集", href: "/"},
      %{text: "カスタムグループの削除", href: "/"}
    ]

    assigns =
      assigns
      |> assign(:menu_items, menu_items)

    ~H"""

    <div>
    <h5>関わっているユーザー</h5>
    <.tab id="tab-single-default" tabs={["気になる人", "チーム", "採用候補者"]} previous_enable menu_items={@menu_items}>
    <.inner_tab />
    <.intriguing_card_body />
    </.tab>
    </div>
    """
  end

  @spec intriguing_card_body(any) :: Phoenix.LiveView.Rendered.t()
  def intriguing_card_body(assigns) do
    ~H"""
    <div class="pt-3 pb-1 px-6">
     <ul class="flex flex-wrap gap-y-1">
       <li
         class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
       >
         <a class="inline-flex items-center gap-x-6">
           <img
             class="inline-block h-10 w-10 rounded-full"
             src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
           />
           <div>
             <p>nokichi</p>
             <p class="text-brightGray-300">アプリエンジニア</p>
           </div>
         </a>
       </li>
       <li
         class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
       >
         <a class="inline-flex items-center gap-x-6">
           <img
             class="inline-block h-10 w-10 rounded-full"
             src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
           />
           <div>
             <p>nokichi</p>
             <p class="text-brightGray-300">アプリエンジニア</p>
           </div>
         </a>
       </li>
       <li
         class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
       >
         <a class="inline-flex items-center gap-x-6">
           <img
             class="inline-block h-10 w-10 rounded-full"
             src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
           />
           <div>
             <p>nokichi</p>
             <p class="text-brightGray-300">アプリエンジニア</p>
           </div>
         </a>
       </li>
       <li
         class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
       >
         <a class="inline-flex items-center gap-x-6">
           <img
             class="inline-block h-10 w-10 rounded-full"
             src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
           />
           <div>
             <p>nokichi</p>
             <p class="text-brightGray-300">アプリエンジニア</p>
           </div>
         </a>
       </li>
       <li
         class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2"
       >
         <a class="inline-flex items-center gap-x-6">
           <img
             class="inline-block h-10 w-10 rounded-full"
             src="https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&amp;ixid=eyJhcHBfaWQiOjEyMDd9&amp;auto=format&amp;fit=facearea&amp;facepad=2&amp;w=256&amp;h=256&amp;q=80"
           />
           <div>
             <p>nokichi</p>
             <p class="text-brightGray-300">アプリエンジニア</p>
           </div>
         </a>
       </li>
     </ul>
    </div>
    """
  end

  def inner_tab(assigns) do
    ~H"""
    <!-- tab2 -->
    <div class="overflow-hidden">
      <ul
        class="flex border-b border-brightGray-50 text-base !text-sm w-[800px]"
      >
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          キャリアの参考になる方々
        </li>
        <li
          class="py-2 w-[200px] border-r border-brightGray-50 bg-brightGreen-50"
        >
          優秀なエンジニアの方々
        </li>
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          カスタムグループ３
        </li>
        <li class="py-2 w-[200px] border-r border-brightGray-50">
          カスタムグループ４
        </li>
      </ul>
    </div>
    """
  end

  def intriguing_card_row(assigns) do
    """
    <div class="pt-3 pb-1 px-6">
      <ul class="flex flex-wrap gap-y-1">
        <%= for _ <- 1..5 do %>
          <.profile_small />
        <% end %>
      </ul>
    </div>
    """
  end
end
