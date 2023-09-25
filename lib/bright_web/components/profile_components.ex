defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  import BrightWeb.SnsComponents
  alias Phoenix.LiveView.JS
  alias Bright.UserProfiles

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
      |> assign(
        :icon_style,
        "background-repeat: no-repeat; background-image: url('#{icon_file_path}');"
      )
      |> assign(:user_name, user_name)
      |> assign(:title, title)

    ~H"""
    <div class="flex">
      <img class="bg-contain inline-block mr-5 h-16 w-16 rounded-full lg:h-20 lg:w-20" src={@icon_file_path} />
      <div class="flex-1">
        <div class="flex justify-between pb-4 lg:items-end lg:pb-2">
          <div class="text-2xl font-bold"><%= @user_name %></div>
          <div class="flex gap-x-3 mt-2 lg:mt-0">
           <.excellent_person_button :if={@display_excellent_person}/>
           <.anxious_person_button :if={@display_anxious_person} />
           <.profile_button :if={@display_return_to_yourself} phx-click="clear_display_user">自分に戻す</.profile_button>
           <.profile_button :if={@display_stock_candidates_for_employment}>採用候補者としてストック</.profile_button>
           <.profile_button :if={@display_adopt}>採用する</.profile_button>
           <.profile_button :if={@display_recruitment_coordination}>採用の調整</.profile_button>
          </div>
        </div>
        <div class="flex justify-between pt-3 border-brightGray-100 border-t">
          <div class="text-2xl max-w-[600px] break-all"><%= @title %></div>
          <.sns :if={@display_sns} twitter_url={@twitter_url} github_url={@github_url} facebook_url={@facebook_url} />
        </div>
      </div>
    </div>
    <div :if={@display_detail} class="pt-5">
      <%= Phoenix.HTML.Format.text_to_html @detail || "", attributes: [class: "break-all"] %>
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
  attr :encrypt_user_name, :string, default: ""
  attr :click_event, :string, default: ""
  attr :click_target, :string, default: nil

  def profile_small(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-1/2">
      <.profile_small_link click_event={@click_event} click_target={@click_target} user_name={@user_name} encrypt_user_name={@encrypt_user_name}>
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
          src={UserProfiles.icon_url(@icon_file_path)}
        />
        <div class="flex-auto">
          <p><%= @user_name %></p>
          <p class="text-brightGray-300"><%= @title %></p>
        </div>
        <div
          phx-click={JS.push("remove_user", value: %{id: @user_id})}
          phx-target={@remove_user_target}
          class="mx-4 cursor-pointer"
        >
          <span
            class="material-icons !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center"
          >
            close
          </span>
        </div>
      </a>
    </li>
    """
  end

  @doc """
  Renders a Profile for stock small with remove button

  ## Examples
      <.profile_stock_small_with_remove_button
        remove_user_target={@myself}
        stok_id="1234"
        stock_date="2023-09-02"
        skill_panel="Webアプリ開発 Elixir"
        desired_income="1000"
      />
  """
  attr :remove_user_target, :any
  attr :stock_id, :string, required: true
  attr :stock_date, :string, required: true
  attr :skill_panel, :string, required: true
  attr :desired_income, :string, default: ""
  attr :encrypt_user_name, :string, required: true
  attr :click_event, :string, default: ""
  attr :click_target, :string, default: nil

  def profile_stock_small_with_remove_button(assigns) do
    ~H"""
    <li class="relative text-left flex items-center text-base p-1  bg-white w-1/2">
      <.profile_stock_small_link click_event={@click_event} click_target={@click_target} encrypt_user_name={@encrypt_user_name}>
        <img
          class="inline-block h-10 w-10 rounded-full"
          src="/images/avatar.png"
        />
        <div class="flex-auto gap-x-2">
          <p>検索：<%= @skill_panel %></p>
          <span class="text-brightGray-300">(<%= @stock_date %>)</span>
          <span class="text-brightGray-300">希望年収：<%= @desired_income %></span>
        </div>
      </.profile_stock_small_link>
      <button
        phx-click={JS.push("remove_user", value: %{stock_id: @stock_id})}
        phx-target={@remove_user_target}
        class="absolute top-1 right-4"
      >
        <span class="material-icons bg-brightGray-900 !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center text-white">
          close
        </span>
      </button>
    </li>
    """
  end

  # 基本プロフィール マイページ遷移用リンク
  defp profile_small_link(%{click_event: nil} = assigns) do
    user_name =
      if assigns.encrypt_user_name == "",
        do: assigns.user_name,
        else: "anon/#{assigns.encrypt_user_name}"

    assigns = assign(assigns, :user_name, user_name)

    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" href={"/mypage/#{@user_name}"}>
      <span class="inline-flex items-center gap-x-6">
        <%= render_slot(@inner_block) %>
      </span>
    </a>
    """
  end

  # 基本プロフィール root LiveView用イベント
  defp profile_small_link(%{click_event: _, click_target: nil} = assigns) do
    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" phx-click={@click_event} phx-value-name={@user_name} phx-value-encrypt_user_name={@encrypt_user_name}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # 基本プロフィール LiveComponent用イベント
  defp profile_small_link(assigns) do
    ~H"""
    <a class="cursor-pointer inline-flex items-center gap-x-6" phx-click={@click_event} phx-target={@click_target} phx-value-name={@user_name} phx-value-encrypt_user_name={@encrypt_user_name}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # 採用候補者 マイページ遷移用リンク
  defp profile_stock_small_link(%{click_event: nil} = assigns) do
    ~H"""
    <.link
      class="inline-flex items-center gap-x-6 w-full hover:bg-brightGray-50"
      href={"/mypage/anon/#{@encrypt_user_name}"}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # 採用候補者 root LiveView用イベント
  # 成長グラフ／スキルパネルのメガメニューで利用
  defp profile_stock_small_link(%{click_event: _, click_target: nil} = assigns) do
    ~H"""
    <.link
      class="inline-flex items-center gap-x-6 w-full hover:bg-brightGray-50"
      phx-click={@click_event}
      phx-value-encrypt_user_name={@encrypt_user_name}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  # 採用候補者 LiveComponent用イベント
  # スキルパネル「個人と比較」で利用
  defp profile_stock_small_link(assigns) do
    ~H"""
    <.link
      class="inline-flex items-center gap-x-6 w-full hover:bg-brightGray-50"
      phx-click={@click_event}
      phx-target={@click_target}
      phx-value-encrypt_user_name={@encrypt_user_name}
    >
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end
end
