defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  import BrightWeb.SnsComponents

  @doc """
  Renders a Profile

  ## Examples
      <.profile
        user_name="piacere"
        title="リードプログラマー"
        detail="高校・大学と野球部に入っていました。チームで開発を行うような仕事が得意です。メインで使っている言語はJavaで中規模～大規模のシステム開発を受け持っています。最近Elixirを学び始め、Elixirで仕事ができると嬉しいです。"
        icon_file_path="/images/sample/sample-image.png"
        display_excellent_person
        display_anxious_person
        display_return_to_yourself
        display_stock_candidates_for_employment
        display_adopt
        display_recruitment_coordination
        display_sns
        twitter_url="https://twitter.com/"
        github_url="https://www.github.com/"
        facebook_url="https://www.facebook.com/"
      />
  """
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :detail, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :display_excellent_person, :boolean, default: false
  attr :display_anxious_person, :boolean, default: false
  attr :display_return_to_yourself, :boolean, default: false
  attr :display_stock_candidates_for_employment, :boolean, default: false
  attr :display_adopt, :boolean, default: false
  attr :display_recruitment_coordination, :boolean, default: false
  attr :display_sns, :boolean, default: false
  attr :twitter_url, :string, default: ""
  attr :facebook_url, :string, default: ""
  attr :github_url, :string, default: ""

  def profile(assigns) do
    assigns =
      assigns
      |> assign(:icon_style, "background-image: url('#{assigns.icon_file_path}');")

    ~H"""
    <div class="w-[850px] pt-4">
      <div class="flex">
        <div class="bg-test bg-contain h-20 w-20 mr-5" style={@icon_style}></div>
        <div class="flex-1">
          <div class="flex justify-between pb-2 items-end">
            <div class="text-2xl font-bold"><%= assigns.user_name %></div>
            <div class="flex gap-x-3">
              <%= if assigns.display_excellent_person do %>
                <.excellent_person_button />
              <% end %>

              <%= if assigns.display_anxious_person do %>
                <.anxious_person_button />
              <% end %>

              <%= if assigns.display_return_to_yourself do %>
                <.return_to_yourself_button />
              <% end %>

              <%= if assigns.display_stock_candidates_for_employment do %>
                <.stock_candidates_for_employment_button />
              <% end %>

              <%= if assigns.display_adopt do %>
                <.adopt_button />
              <% end %>

              <%= if assigns.display_recruitment_coordination do %>
                <.recruitment_coordination_button />
              <% end %>
            </div>
          </div>

          <div class="flex justify-between pt-3 border-brightGray-100 border-t">
            <div class="text-2xl"><%= assigns.title %></div>
            <%= if assigns.display_sns do %>
              <.sns twitter_url={@twitter_url} github_url={@github_url} facebook_url={@facebook_url} />
            <% end %>
          </div>
        </div>
      </div>
      <div class="pt-5">
        <%= assigns.detail %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a Profile small

  ## Examples
      <.profile_snall/>
  """
  def profile_small(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2">
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
    """
  end
end
