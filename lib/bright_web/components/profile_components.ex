defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  import BrightWeb.SnsComponents
  alias Phoenix.LiveView.JS

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
  attr :is_anonymous, :boolean, default: false
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :detail, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :display_detail, :boolean, default: true
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
    icon_file_path =
      if assigns.is_anonymous, do: "/images/avatar.png", else: assigns.icon_file_path

    user_name = if assigns.is_anonymous, do: "非表示", else: assigns.user_name
    title = if assigns.is_anonymous, do: "非表示", else: assigns.title

    assigns =
      assigns
      |> assign(:icon_style, "background-image: url('#{icon_file_path}');")
      |> assign(:user_name, user_name)
      |> assign(:title, title)

    ~H"""
    <div class="flex">
      <div class="bg-test bg-contain h-20 w-20 mr-5" style={@icon_style}></div>
      <div class="flex-1">
        <div class="flex justify-between pb-2 items-end">
          <div class="text-2xl font-bold"><%= @user_name %></div>
          <div class="flex gap-x-3">
           <.excellent_person_button :if={@display_excellent_person}/>
           <.anxious_person_button :if={@display_anxious_person} />
           <.profile_button :if={@display_return_to_yourself} phx-click="clear_target_user">自分に戻す</.profile_button>
           <.profile_button :if={@display_stock_candidates_for_employment}>採用候補者としてストック</.profile_button>
           <.profile_button :if={@display_adopt}>採用する</.profile_button>
           <.profile_button :if={@display_recruitment_coordination}>採用の調整</.profile_button>
          </div>
        </div>
        <div class="flex justify-between pt-3 border-brightGray-100 border-t">
          <div class="text-2xl"><%= @title %></div>
          <.sns :if={@display_sns} twitter_url={@twitter_url} github_url={@github_url} facebook_url={@facebook_url} />
        </div>
      </div>
    </div>
    <div :if={@display_detail} class="pt-5">
      <%= @detail %>
    </div>
    """
  end

  @doc """
  Renders a Profile small

  ## Examples
      <.profile_small
        user_name="piacere"
        title="リードプログラマー"
        icon_file_path="/images/sample/sample-image.png"
      />
  """
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :click_event, :string, default: ""
  attr :click_target, :string, default: nil

  def profile_small(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2">
      <.profile_small_link click_event={@click_event} click_target={@click_target} user_name={@user_name}>
        <img class="inline-block h-10 w-10 rounded-full" src={@icon_file_path} />
        <div>
          <p><%= @user_name %></p>
          <p class="text-brightGray-300"><%= @title %></p>
        </div>
      </.profile_small_link>
    </li>
    """
  end

  @doc """
  Renders a Profile small with remove button

  ## Examples
      <.profile_small_with_remove_button
        remove_user_target={@myself}
        user_name="piacere"
        user_id="1234"
        title="リードプログラマー"
        icon_file_path="/images/sample/sample-image.png"
      />
  """
  attr :remove_user_target, :any
  attr :user_name, :string, required: true
  attr :user_id, :string, required: true
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""

  def profile_small_with_remove_button(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full">
      <a class="inline-flex items-center gap-x-6 w-full">
        <img
          class="inline-block h-10 w-10 rounded-full"
          src={@icon_file_path}
        />
        <div class="flex-auto">
          <p><%= @user_name %></p>
          <p class="text-brightGray-300"><%= @title %></p>
        </div>
        <button
          phx-click={JS.push("remove_user", value: %{id: @user_id})}
          phx-target={@remove_user_target}
          class="mx-4"
        >
          <span class="material-icons bg-brightGray-900 !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center text-white">
            close
          </span>
        </button>
      </a>
    </li>
    """
  end

  defp profile_small_link(%{click_event: nil} = assigns) do
    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" href={"/mypage/#{@user_name}"}>
      <span class="inline-flex items-center gap-x-6">
        <%= render_slot(@inner_block) %>
      </span>
    </a>
    """
  end

  defp profile_small_link(%{click_event: _, click_target: nil} = assigns) do
    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" phx-click={@click_event} phx-value-name={@user_name}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  defp profile_small_link(assigns) do
    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" phx-click={@click_event} phx-target={@click_target} phx-value-name={@user_name}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end
end
