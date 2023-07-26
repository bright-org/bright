defmodule BrightWeb.UserSettingsLive.SnsSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="flex flex-col mt-8 full">
        <div class="flex items-center mb-4">
          <button class="bg-bgGoogle bg-5 bg-left-2.5 bg-no-repeat border border-solid border-black font-bold max-w-xs px-4 py-2 rounded select-none text-black text-center w-full hover:opacity-50">Googleと連携する</button>
          <span class="hidden ml-4"><i></i>で連携中</span>
        </div>

        <div class="flex items-center mb-4">
          <button class="bg-bgGithub bg-5 bg-left-2.5 bg-sns-github bg-no-repeat border border-github border-solid font-bold max-w-xs px-4 py-2 rounded select-none text-white text-center w-full hover:opacity-50">GitHubと連携解除する</button>
          <span class="block ml-4"><i>piacereex</i>で連携中</span>
        </div>

        <div class="flex items-center mb-4">
          <button class="bg-bgFacebook bg-5 bg-left-2.5 bg-sns-facebook bg-no-repeat border border-facebook border-solid font-bold max-w-xs px-4 py-2 rounded select-none text-white text-center w-full hover:opacity-50">Facebookと連携する</button>
          <span class="hidden ml-4"><i></i>で連携中</span>
        </div>

        <div class="flex items-center mb-4">
          <button class="bg-bgTwitter bg-5 bg-left-2.5 bg-sns-twitter bg-no-repeat border border-twitter border-solid font-bold max-w-xs px-4 py-2 rounded select-none text-white text-center w-full hover:opacity-50">Twitterと連携解除する</button>
          <span class="block ml-4"><i>piacereex</i>で連携中</span>
        </div>
      </div>
    </li>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)}
  end
end
