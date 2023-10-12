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

  slot :inner_block, required: true

  def root_layout(assigns) do
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
        <meta property="og:title" content="Bright｜過去と今、未来のスキルから、あなたの輝きを見える化します">
        <meta property="og:description" content={"ITで世の中に価値をもたらすエンジニアやインフラ、デザイナー、マーケッターから、気になるスキルを選び、あなたがどのような\"輝き\"を放つかを体験してください。"}>
        <meta property="og:image" content="https://bright-fun.org/images/ogp_a.png">
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

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までユーザーヘッダーのみデザイン更新

  ## Examples
      <.user_header />
  """
  attr :profile, :map
  attr :page_title, :string
  attr :page_sub_title, :string

  def user_header(assigns) do
    page_sub_title =
      if assigns.page_sub_title != nil, do: " / #{assigns.page_sub_title}", else: ""

    assigns =
      assigns
      |> assign(:profile, assigns.profile || %UserProfiles.UserProfile{})
      |> assign(:page_sub_title, page_sub_title)

    ~H"""
    <div id="user-header" class="sticky top-0 z-10 flex flex-col-reverse justify-between px-4 py-2 border-brightGray-100 border-b bg-white w-full lg:flex-row lg:items-center lg:px-10 lg:relative">
      <h4 class="lg:hidden font-bold mt-2 text-sm before:bg-bgGem before:bg-6 before:bg-left before:bg-no-repeat before:content-[''] before:h-6 before:inline-block before:align-[-5px] before:w-6">
        <%= @page_title %><%= @page_sub_title %>
      </h4>
      <h4 class="hidden lg:block font-bold lg:mt-0 lg:text-xl">
        <%= @page_title %><%= @page_sub_title %>
      </h4>
      <div class="bg-white fixed bottom-0 left-0 p-2 lg:ml-auto lg:mr-2 lg:static lg:p-0 w-full lg:w-[440px]">
        <div class="flex justify-between">
          <.plan_upgrade_button  />
          <.contact_customer_success_button />
        </div>
      </div>
      <div class="flex gap-2 items-center lg:w-fit h-10">
        <.search_for_skill_holders_button />
        <.notification_button />
        <.user_button icon_file_path={UserProfiles.icon_url(@profile.icon_file_path)}/>
      </div>
    </div>
    """
  end

  @doc """
  Renders a Side Menu

  # TODO 「4211a9a3ea766724d890e7e385b9057b4ddffc52」　「feat: フォームエラー、モーダル追加」　までメニューのみデザイン更新

  ## Examples
      <.side_menu />
  """

  attr :href, :string

  def side_menu(assigns) do
    ~H"""
    <aside class="relative">
      <input id="sp_navi_input" class="hidden peer" type="checkbox">
      <label id="sp_navi_open" class="bg-white block cursor-pointer fixed h-10 ml-4 left-0 rounded top-2 w-10 z-50 lg:hidden" for="sp_navi_input">
        <span class="absolute bg-brightGray-300 block cursor-pointer h-[3px] left-1 top-1.5 w-8 before:bg-brightGray-300 before:block before:content-[''] before:cursor-pointer before:h-[3px] before:absolute before:top-3 before:w-8 after:bg-brightGray-300 after:block after:content-[''] after:cursor-pointer after:h-[3px] after:absolute after:top-6 after:w-8"></span>
      </label>
      <label id="sp_navi_close" for="sp_navi_input" class="cursor-pointer hidden h-full fixed right-0 top-0 w-full z-20 -ml-2"></label>
      <div class="fixed bg-brightGray-900 pt-3 min-h-screen h-full hidden flex-col w-full z-40 lg:flex lg:static lg:w-[200px] peer-checked:flex">
        <.link href="/mypage"><img src="/images/common/logo.svg" width="163px" class="ml-2 lg:ml-4 mt-12 lg:mt-0" /></.link>
        <ul class="grid lg:pt-2">
          <%= for {title, path, regex} <- links() do %>
            <li>
              <.link class={menu_active_style(match_link?(@href, path, regex))} href={path} ><%= title %></.link>
            </li>
          <% end %>
          <li>
            <.link
            href="/users/log_out"
            method="delete"
            class="!text-white text-base py-4 inline-block pl-4 w-full mb"
            >
              ログアウト
            </.link>
          </li>
        </ul>
      </div>
    </aside>
    """
  end

  def links() do
    [
      {"スキルを選ぶ", "/more_skills?open=want_todo_panel", nil},
      {"成長を見る・比較する", "/graphs", nil},
      {"スキルを入力", "/panels", nil},
      {"チームのスキルを見る", "/teams", ~r/\/teams(?!\/new)/},
      {"チームを作る（β）", "/teams/new", nil},
      {"スキル検索する（β）", "/searches", nil}
      # TODO α版はskill_upを表示しない
      # {"スキルアップする", "/skill_up"},
      # {"キャリアパスを選ぶ", "https://bright-fun.org/demo/select_career.html", nil},
    ]
  end

  defp menu_active_style(true),
    do: "!text-white bg-white bg-opacity-30 text-base py-4 inline-block pl-4 w-full mb-1"

  defp menu_active_style(false), do: "!text-white text-base py-4 inline-block pl-4 w-full mb"

  defp match_link?(href, path, nil) do
    String.starts_with?(href, path)
  end

  defp match_link?(href, _path, regex) do
    String.match?(href, regex)
  end
end
