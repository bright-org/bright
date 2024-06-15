defmodule BrightWeb.ProfileComponents do
  @moduledoc """
  Profile Components
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  import BrightWeb.SnsComponents

  import BrightWeb.CoreComponents,
    only: [
      icon: 1
    ]

  alias Phoenix.LiveView.JS
  alias Bright.UserProfiles
  alias BrightWeb.ChartComponents
  alias BrightWeb.SkillPanelLive.SkillPanelComponents
  alias BrightWeb.TeamComponents
  alias Bright.Teams

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
        <div class="flex pb-4 items-end pb-2">
          <div class="text-base lg:text-2xl font-bold max-w-[190px] truncate lg:max-w-[280px]"><%= @user_name %></div>
          <div class="flex gap-x-3 ml-1 lg:ml-4">
           <.excellent_person_button :if={@display_excellent_person}/>
           <.anxious_person_button :if={@display_anxious_person} />
           <.profile_button :if={@display_return_to_yourself} phx-click="clear_display_user">自分に戻す</.profile_button>
           <.profile_button :if={@display_stock_candidates_for_employment}>採用候補者としてストック</.profile_button>
           <.profile_button :if={@display_adopt}>採用する</.profile_button>
           <.profile_button :if={@display_recruitment_coordination}>採用の調整</.profile_button>
          </div>
        </div>
        <div class="flex flex-col lg:flex-row justify-between pt-3 border-brightGray-100 border-t w-64 lg:w-full">
          <div class="text-sm lg:text-xl mb-4 max-w-[600px] break-all"><%= @title %></div>
          <.sns :if={@display_sns} twitter_url={@twitter_url} github_url={@github_url} facebook_url={@facebook_url} />
        </div>
      </div>
    </div>
    <div :if={@display_detail} class="pt-5">
      <%= Phoenix.HTML.Format.text_to_html @detail || "", attributes: [class: "break-all"] %>
    </div>
    """
  end

  attr :is_anonymous, :boolean, default: false
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :display_return_to_yourself, :boolean, default: false
  attr :display_stock_candidates_for_employment, :boolean, default: false
  attr :display_adopt, :boolean, default: false
  attr :display_recruitment_coordination, :boolean, default: false
  attr :display_sns, :boolean, default: false
  attr :twitter_url, :string, default: ""
  attr :facebook_url, :string, default: ""
  attr :github_url, :string, default: ""

  def profile_inline(assigns) do
    assigns = assign_by_anonymous(assigns)

    ~H"""
    <div class="flex">
      <div class="mr-2 lg:mr-5 w-12 lg:w-20">
        <img
          class="object-cover inline-block h-[42px] w-[42px] lg:h-16 lg:w-16 rounded-full"
          src={@icon_file_path}
        />
      </div>
      <div class="flex justify-between lg:justify-start mt-2 lg:mt-4 w-full">
        <div class="text-md max-w-[155px] lg:max-w-[290px] truncate lg:text-2xl font-bold lg:-mt-[4px]"><%= @user_name %></div>
        <div class="flex flex-col lg:flex-row">
          <div class="flex gap-x-3 h-6 lg:h-8 ml-7 lg:ml-9">
            <.profile_button :if={@display_return_to_yourself} phx-click="clear_display_user">自分に戻す</.profile_button>
            <.profile_button :if={@display_stock_candidates_for_employment}>採用候補者としてストック</.profile_button>
            <.profile_button :if={@display_adopt}>採用する</.profile_button>
            <.profile_button :if={@display_recruitment_coordination}>採用の調整</.profile_button>
          </div>
          <div class="mt-1 lg:mt-0 lg:ml-4">
            <.sns :if={@display_sns} twitter_url={@twitter_url} github_url={@github_url} facebook_url={@facebook_url} />
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :display_team, :map
  attr :current_users_team_member, Bright.Teams.TeamMemberUsers, required: false, default: nil
  attr :team_size, :integer, default: 0
  attr :skill_class, :any, required: true
  attr :skill_panel, :any, required: true
  slot :switch_button, default: nil

  def profile_with_selected_team(assigns) do
    assigns = assign_by_anonymous(assigns)

    ~H"""
      <div class="flex flex-col gap-y-2 w-full">
        <div class="flex flex-col lg:flex-row gap-y-2 lg:gap-x-4">
          <h4 class="w-full lg:w-auto">選択中のチーム／スキル</h4>
        </div>
        <div class=" p-4 lg:px-6 bg-white rounded-lg">
          <div class="flex flex-col lg:flex-row gap-x-8 gap-y-4 lg:gap-y-0">
            <TeamComponents.team_title
              team_name={@display_team.name}
              team_type={Teams.get_team_type_by_team(@display_team)}
              current_users_team_member={@current_users_team_member}
              team_size={@team_size}
            />
            <.selected_skill
              skill_panel={@skill_panel}
              skill_class={@skill_class}
            />
          </div>
          <%= if @switch_button, do: render_slot(@switch_button) %>
        </div>
      </div>
    """
  end

  defp selected_skill_title(assigns) do
    ~H"""
      <div class="flex flex-col lg:flex-row gap-y-2 lg:gap-x-4">
        <h4 class="w-full lg:w-auto">選択中のユーザー／スキル／クラス</h4>
        <div>
          <.profile_button :if={@display_return_to_yourself} phx-click="clear_display_user">
            <.icon name="hero-arrow-uturn-right" class="mr-2" />
            自分に戻す
          </.profile_button>
        </div>
      </div>
    """
  end

  defp selected_user(assigns) do
    ~H"""
      <div class="flex flex-col lg:flex-row justify-center items-center">
        <div class="lg:mr-5 w-12 lg:w-20">
          <img
            class="object-cover inline-block h-[42px] w-[42px] lg:h-16 lg:w-16 rounded-full"
            src={@icon_file_path}
          />
        </div>
        <div class="flex mr-2 lg:mr-20">
          <div class="text-md max-w-[155px] lg:max-w-[290px] truncate lg:text-2xl font-bold lg:-mt-[4px]"><%= @user_name %></div>
        </div>
      </div>
    """
  end

  defp selected_skill(assigns) do
    ~H"""
      <div class="flex flex-col gap-y-2 font-bold justify-center">
        <span id="profile-skill-panel-name" class="text-md lg:text-2xl"><%= if @skill_panel, do: @skill_panel.name, else: "" %></span>
        <div class="flex flex-col lg:flex-row gap-x-4 gap-y-2 lg:gap-y-0">
          <span class="text-sm lg:text-normal">クラス<%= if @skill_class, do: @skill_class.class, else: "" %></span>
          <span class="text-sm lg:text-normal break-all"><%= if @skill_class, do: @skill_class.name, else: ""  %></span>
        </div>
      </div>
    """
  end

  attr :is_anonymous, :boolean, default: false
  attr :me, :boolean, default: false
  attr :is_star, :boolean, default: false
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :skill_class, :any, required: true
  attr :skill_panel, :any, required: true
  attr :display_return_to_yourself, :boolean, default: false
  slot :score_stats, default: nil
  slot :switch_button, default: nil

  def profile_with_skill(assigns) do
    assigns = assign_by_anonymous(assigns)

    ~H"""
      <div class="flex flex-col gap-y-2 w-full">
        <.selected_skill_title display_return_to_yourself={@display_return_to_yourself} />
        <div class="p-4 lg:px-6 bg-white rounded-lg">
          <div class="flex flex-col lg:flex-row gap-x-8 gap-y-2 lg:gap-y-0">
            <div class="flex gap-x-4 lg:gap-x-0">
              <.selected_user icon_file_path={@icon_file_path} user_name={@user_name} />
              <.selected_skill
                skill_panel={@skill_panel}
                skill_class={@skill_class}
              />
            </div>
            <div class="pt-4" :if={@me}>
              <button
                class={"bg-white border border-#{get_star_style(@is_star)} rounded px-1 h-8 flex items-center mt-auto mb-1 hover:filter hover:brightness-95"}
                phx-click="click_star_button"
              >
                <span class={"material-icons text-#{get_star_style(@is_star)}"}>
                  star
                </span>
              </button>
            </div>
            <%= if @score_stats, do: render_slot(@score_stats) %>
          </div>
          <%= if @switch_button, do: render_slot(@switch_button) %>
        </div>
      </div>
    """
  end

  def dounat_graph_with_score_stats(assigns) do
    ~H"""
      <div class="flex gap-x-4 lg:gap-x-0">
        <div class="w-20 lg:w-24 h-20 lg:h-24">
          <ChartComponents.doughnut_graph id="doughnut-graph-single" data={SkillPanelComponents.skill_score_percentages(@counter, @num_skills)} />
        </div>

        <SkillPanelComponents.profile_score_stats
          skill_class_score={@skill_class_score}
          counter={@counter}
          num_skills={@num_skills}
        />
      </div>
    """
  end

  defp assign_by_anonymous(%{is_anonymous: true} = assigns) do
    assigns
    |> assign(:icon_file_path, "/images/avatar.png")
    |> assign(:user_name, "非表示")
    |> assign(:title, "非表示")
  end

  defp assign_by_anonymous(assigns) do
    assigns
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
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded w-full lg:w-1/2">
      <.profile_small_link click_event={@click_event} click_target={@click_target} user_name={@user_name} encrypt_user_name={@encrypt_user_name}>
        <img class="inline-block h-10 w-10 rounded-full" src={@icon_file_path} />
        <div>
          <p class="truncate max-w-[240px]"><%= @user_name %></p>
          <p class="text-brightGray-300"><%= @title %></p>
        </div>
      </.profile_small_link>
    </li>
    """
  end

  @doc """
  Renders a Profile small for inline

  ## Examples
      <.profile_small_inline
        user_name="piacere"
        title="リードプログラマー"
        icon_file_path="/images/sample/sample-image.png"
      />
  """
  attr :user_name, :string, default: ""
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :detail, :string, default: ""

  def profile_small_inline(assigns) do
    ~H"""
    <div class="text-left flex gap-x-8 text-base p-1 rounded w-full">
      <img class="inline-block h-10 w-10 rounded-full -mr-4" src={@icon_file_path} />
      <p class="truncate max-w-[240px] mt-2"><%= @user_name %></p>
      <p class="text-brightGray-300 max-w-[420px] mt-2"><%= @title %></p>
      <p class="max-w-[520px] overflow-hidden mt-2"><%= @detail %></p>
    </div>
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
        not_invitation_confirmed="未承認"
      />
  """
  attr :remove_user_target, :any
  attr :user_name, :string, required: true
  attr :user_id, :string, required: true
  attr :title, :string, default: ""
  attr :icon_file_path, :string, default: ""
  attr :not_invitation_confirmed, :string, default: nil

  def profile_small_with_remove_button(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base hover:bg-brightGray-50 p-1 rounded border border-brightGray-100 bg-white w-full">
      <a class="inline-flex items-center gap-x-2 w-full">
        <img
          class="inline-block h-10 w-10 rounded-full"
          src={UserProfiles.icon_url(@icon_file_path)}
        />
        <div class="flex-auto">
          <p class="truncate max-w-[120px]"><%= @user_name %></p>
          <p class="text-brightGray-300"><%= @title %></p>
        </div>
        <span
        :if={@not_invitation_confirmed}
        class="text-white text-xs font-bold ml-1 px-1 py-1 inline-block bg-lapislazuli-300 rounded min-w-[43px]"
        >
          <%= @not_invitation_confirmed %>
        </span>
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
  Renders a Profile mini

  ## Examples
      <.profile_mini
        user_name="piacere"
        icon_file_path="/images/sample/sample-image.png"
      />
  """
  attr :user_name, :string, default: ""
  attr :icon_file_path, :string, default: ""

  def profile_mini(assigns) do
    ~H"""
    <li class="text-left flex items-center text-base p-1 rounded w-full">
      <img class="inline-block h-6 w-6 rounded-full" src={@icon_file_path} />
      <div>
        <p class="pl-1 truncate max-w-[240px]"><%= @user_name %></p>
      </div>
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
  attr :user_id, :string, default: ""
  attr :stock_date, :string, required: true
  attr :skill_panel, :string, required: true
  attr :desired_income, :string, default: ""
  attr :encrypt_user_name, :string, required: true
  attr :click_event, :string, default: ""
  attr :click_target, :string, default: nil
  attr :hr_enabled, :boolean, default: false

  def profile_stock_small_with_remove_button(%{hr_enabled: false} = assigns) do
    ~H"""
    <li class="relative text-left flex items-center text-base p-1  bg-white w-full lg:w-1/2">
      <.profile_stock_small_link click_event={@click_event} click_target={@click_target} encrypt_user_name={@encrypt_user_name}>
        <img
          class="inline-block h-10 w-10 rounded-full"
          src="/images/avatar.png"
        />
        <div class="flex-auto gap-x-2">
          <p class="truncate max-w-[240px]">検索：<%= @skill_panel %></p>
          <span class="text-brightGray-300">(<%= @stock_date %>)</span>
          <span class="text-brightGray-300">希望年収：<%= @desired_income %></span>
        </div>
      </.profile_stock_small_link>
      <button
        phx-click={JS.push("remove_user", value: %{stock_id: @stock_id})}
        phx-target={@remove_user_target}
        class="absolute top-0 -right-4 lg:right-2"
      >
        <span class="material-icons bg-brightGray-900 !text-sm rounded-full !inline-flex w-4 h-4 !items-center !justify-center text-white">
          close
        </span>
      </button>
    </li>
    """
  end

  def profile_stock_small_with_remove_button(%{hr_enabled: true} = assigns) do
    assigns =
      Map.put(
        assigns,
        :skill_params,
        Bright.UserSearches.generate_search_params_from_skill_panel_name(assigns.skill_panel)
      )

    ~H"""
    <li class="relative text-left flex items-center text-base p-1  bg-white w-full lg:w-1/2">
      <.link
        phx-click={
          JS.show(to: "#create_interview_modal")
          |> JS.push("open", value: %{user: @user_id, skill_params: @skill_params}, target: "#create_interview_modal")
        }
        class="cursor-pointer w-full inline-flex items-center gap-x-6"
      >
        <img
          class="inline-block h-10 w-10 rounded-full"
          src="/images/avatar.png"
        />
        <div class="flex-auto gap-x-2">
          <p class="truncate max-w-[240px]">検索：<%= @skill_panel %></p>
          <span class="text-brightGray-300">(<%= @stock_date %>)</span>
          <span class="text-brightGray-300">希望年収：<%= @desired_income %></span>
        </div>
      </.link>
      <button
        phx-click={JS.push("remove_user", value: %{stock_id: @stock_id})}
        phx-target={@remove_user_target}
        class="absolute top-0 -right-4 lg:right-2"
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
    <a class="cursor-pointer w-full inline-flex items-center gap-x-6" href={"/mypage/#{@user_name}"}>
      <span class="inline-flex items-center gap-x-6">
        <%= render_slot(@inner_block) %>
      </span>
    </a>
    """
  end

  # 基本プロフィール root LiveView用イベント
  defp profile_small_link(%{click_event: _, click_target: nil} = assigns) do
    ~H"""
    <a class="cursor-pointer w-full inline-flex items-center gap-x-6" phx-click={@click_event} phx-value-name={@user_name} phx-value-encrypt_user_name={@encrypt_user_name}>
      <%= render_slot(@inner_block) %>
    </a>
    """
  end

  # 基本プロフィール LiveComponent用イベント
  defp profile_small_link(assigns) do
    ~H"""
    <a class="cursor-pointer w-full inline-flex items-center gap-x-6" phx-click={@click_event} phx-target={@click_target} phx-value-name={@user_name} phx-value-encrypt_user_name={@encrypt_user_name}>
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
  # 成長パネル／スキルパネルのメガメニューで利用
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
  # スキルパネル「個人とスキルを比較」で利用
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

  defp get_star_style(true), do: "brightGreen-300"
  defp get_star_style(false), do: "brightGray-500"
end
