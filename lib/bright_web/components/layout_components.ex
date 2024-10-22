defmodule BrightWeb.LayoutComponents do
  @moduledoc """
  LayoutComponents
  """
  use Phoenix.Component
  import BrightWeb.BrightButtonComponents
  alias Bright.UserProfiles

  @doc """
  Renders root layout.
  """

  attr :csrf_token, :string, required: true
  attr :user_id, :string, required: true
  attr :page_title, :string
  attr :enable_google_tag_manager, :boolean, default: true
  attr :og_image, :string, default: "https://bright-fun.org/images/ogp_a.png"
  slot :inner_block, required: true

  def root_layout(assigns) do
    og_image =
      if is_nil(assigns.og_image),
        do: "https://bright-fun.org/images/ogp_a.png",
        else: assigns.og_image

    assigns = assign(assigns, og_image: og_image)

    ~H"""
    <!DOCTYPE html>
    <html lang="ja">
      <head>
        <script :if={@enable_google_tag_manager && Bright.Utils.Env.prod?()}>
          dataLayer = [{
            'user_id': "<%= @user_id %>",
          }];
        </script>
        <!-- Google Tag Manager -->
        <script :if={@enable_google_tag_manager && Bright.Utils.Env.prod?()}>(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
        new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
        j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
        'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
        })(window,document,'script','dataLayer','GTM-P98L4WM');</script>
        <!-- End Google Tag Manager -->
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <meta name="csrf-token" content={@csrf_token} />
        <meta name="twitter:card" content="summary_large_image">
        <meta property="og:title" content="Bright｜過去と今、未来のスキルから、あなたの輝きを見える化します">
        <meta property="og:description" content={"ITで世の中に価値をもたらすエンジニアやインフラ、デザイナー、マーケッターから、気になるスキルを選び、あなたがどのような\"輝き\"を放つかを体験してください。"}>
        <meta property="og:image" content={@og_image}>
        <meta property="og:image:width" content="1200" />
        <meta property="og:image:height" content="630" />
        <meta property="og:type" content="article">
        <meta property="og:url" contetnt="https://bright-fun.org/">
        <.live_title>
          <%= @page_title || "Bright" %>
        </.live_title>
        <link phx-track-static rel="stylesheet" href={"/assets/app.css"} />
        <script defer phx-track-static type="text/javascript" src={"/assets/app.js"}>
        </script>
        <link rel="icon" href={"/favicon.ico"} />
        <link rel="apple-touch-icon" sizes="180x180" href={"/apple-touch-icon.png"} />
      </head>
      <%= render_slot(@inner_block) %>
    </html>
    """
  end

  def google_tag_manager_noscript(assigns) do
    ~H"""
    <!-- Google Tag Manager (noscript) -->
    <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-P98L4WM"
    height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
    <!-- End Google Tag Manager (noscript) -->
    """
  end

  @doc """
  Renders a User Header

  ## Examples
      <.user_header />
  """
  attr :profile, :map
  attr :current_user, :map
  attr :page_title, :string
  attr :page_sub_title, :string

  def user_header(assigns) do
    assigns =
      assigns
      |> assign(:profile, assigns.profile || %UserProfiles.UserProfile{})

    ~H"""
    <div id="user-header" class="sticky top-0 z-40 flex flex-col-reverse justify-between px-4 py-2 border-brightGray-100 border-b bg-white w-full lg:flex-row lg:items-center lg:px-10 lg:relative">
      <div class="bg-white fixed bottom-0 left-0 p-2 lg:mr-2 lg:static lg:p-0 w-full lg:w-[720px]">
        <div class="flex justify-between gap-2">
          <.page_top_title
            page_title={@page_title}
            page_sub_title={@page_sub_title}
          />
          <.plan_upgrade_button />
          <.contact_customer_success_button />
        </div>
      </div>
      <div class="flex gap-2 items-center lg:w-fit h-10">
        <.search_for_skill_holders_button />
        <.live_component
          id="notification_header"
          module={BrightWeb.NotificationLive.NotificationHeaderComponent}
          current_user={Map.get(assigns, :current_user)}
        />
        <.live_component
          id="recruit_notification_header"
          module={BrightWeb.RecruitNotificationHeaderComponent}
          current_user={Map.get(assigns, :current_user)}
        />

        <.user_button icon_file_path={UserProfiles.icon_url(@profile.icon_file_path)}/>
      </div>
    </div>
    """
  end

  @doc """
  Renders a header for Share Graph
  """

  def share_graph_header(assigns) do
    ~H"""
    <div id="user-share-header" class="bg-white sticky w-full top-0 z-40 flex justify-between px-4 lg:px-10 py-2 border-brightGray-100 border-b lg:flex-row lg:items-center lg:relative">
      <div class="w-full">
        <.link href={"/users/register"}>
          <button class="text-center bg-brightGreen-300 font-bold text-xl mx-auto px-4 py-2 rounded-md text-white hover:filter hover:brightness-[80%]">
            Brightを体験してみる
          </button>
        </.link>
      </div>
    </div>
    """
  end

  @doc """
  Renders a page title.

  ## Examples
      <.page_top_title />
  """
  attr :page_title, :string
  attr :page_sub_title, :string

  def page_top_title(assigns) do
    page_sub_title =
      if assigns.page_sub_title != nil, do: " / #{assigns.page_sub_title}", else: ""

    assigns =
      assigns
      |> assign(:page_sub_title, page_sub_title)

    ~H"""
    <h3 id="page-top-title" class="lg:w-64 hidden lg:block">
      <%= @page_title %><%= @page_sub_title %>
    </h3>
    """
  end

  @doc """
  Renders a Side Menu

  ## Examples
      <.side_menu />
  """

  attr :href, :string

  def side_menu(assigns) do
    ~H"""
    <aside class="relative z-50 lg:z-20 lg:w-[110px]">
      <input id="sp_navi_input" class="hidden peer" type="checkbox">
      <label id="sp_navi_open" class="bg-white block cursor-pointer fixed h-10 ml-4 left-0 rounded top-2 w-10 z-[60] peer-checked:z-0 lg:hidden" for="sp_navi_input">
        <span class="absolute bg-brightGray-300 block cursor-pointer h-[3px] left-1 top-1.5 w-8 before:bg-brightGray-300 before:block before:content-[''] before:cursor-pointer before:h-[3px] before:absolute before:top-3 before:w-8 after:bg-brightGray-300 after:block after:content-[''] after:cursor-pointer after:h-[3px] after:absolute after:top-6 after:w-8"></span>
      </label>
      <label id="sp_navi_background" for="sp_navi_input" class="cursor-pointer hidden peer-checked:block bg-pureGray-600/90 h-full fixed right-0 top-0 w-full z-20 -ml-2"></label>
      <div class="lg:gap-y-10 pt-2 fixed bg-brightGray-900 min-h-svh h-full overflow-y-scroll lg:overflow-y-visible flex-col w-[110px] z-40 lg:flex lg:items-center lg:static hidden peer-checked:flex peer-checked:animate-fade-in-left">
        <.link href="/mypage"><img src="/images/common/logo.svg" width="110" class="hidden lg:block" /></.link>
        <ul class="grid lg:flex lg:flex-col lg:items-center lg:gap-y-2">
          <%= for {title, path, regex, img_src} <- links() do %>
            <li>
              <.link class={menu_active_style(match_link?(@href, path, regex))} href={path}>
                <img src={img_src} alt="path image">
                <%= title %>
              </.link>
            </li>
          <% end %>
          <li>
            <.link
            href="/users/log_out"
            method="delete"
            class="hover:bg-brightGray-500 content-center flex flex-col gap-1 lg:gap-2 h-16 lg:h-20 items-center justify-center rounded font-bold text-xs text-white w-[110px]"
            >
              <img src= "/images/common/icons/logout.svg" alt="path image">
              ログアウト
            </.link>
          </li>
        </ul>
      </div>
    </aside>
    """
  end

  # {title, path, regex, img_src}
  def links() do
    [
      {"マイページ", "/mypage", nil, "/images/common/icons/mypage.svg"},
      {"スキルを選ぶ", "/skill_select", nil, "/images/common/icons/skillSelect.svg"},
      {"スキル入力・比較", "/skills", nil, "/images/common/icons/growthPanel.svg"},
      {"成長履歴", "/graphs", nil, "/images/common/icons/mySkill.svg"},
      {"チームスキル分析", "/teams", ~r/\/teams(?!\/new)/, "/images/common/icons/skillAnalyze.svg"},
      {"面談チャット", "/recruits/chats", nil, "/images/common/icons/oneOnOneChat.svg"}
      # TODO α版はskill_upを表示しない
      # {"スキルアップする", "/skill_up"},
      # {"キャリアパスを選ぶ", "https://bright-fun.org/demo/select_career.html", nil},
    ]
  end

  defp menu_active_style(true),
    do:
      "bg-white bg-opacity-30 hover:bg-brightGray-500 content-center flex flex-col gap-1 lg:gap-2 h-16 lg:h-20 items-center justify-center font-bold text-xs text-white w-[110px]"

  defp menu_active_style(false),
    do:
      "hover:bg-brightGray-500 content-center flex flex-col gap-1 lg:gap-2 h-16 lg:h-20 items-center justify-center font-bold text-xs text-white w-[110px]"

  defp match_link?(href, path, nil) do
    String.starts_with?(href, path)
  end

  defp match_link?(href, _path, regex) do
    String.match?(href, regex)
  end
end
