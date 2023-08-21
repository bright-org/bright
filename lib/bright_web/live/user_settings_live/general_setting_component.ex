defmodule BrightWeb.UserSettingsLive.GeneralSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="border-b border-brightGray-200 flex flex-wrap text-left">
        <div class="w-1/2">
          <label class="border-b border-brightGray-200 flex items-center py-4">
            <span class="w-32">ハンドル名</span>
            <input type="text" size="20" name="hn" class="border border-brightGray-200 px-2 py-1 rounded w-60">
          </label>
          <label class="border-b border-brightGray-200 flex items-center py-4">
            <span class="w-32">称号</span>
            <input type="text" size="20" name="title" class="border border-brightGray-200 px-2 py-1 rounded w-60">
          </label>

          <label class="flex items-center pt-4 pb-2">
            <span class="w-32">GitHub</span>
            <input type="text" size="20" name="url_github" class="border border-brightGray-200 px-2 py-1 rounded w-60">
          </label>

          <label class="flex items-center py-2">
            <span class="w-32">Twitter</span>
            <input type="text" size="20" name="url_twitter" class="border border-brightGray-200 px-2 py-1 rounded w-60">
          </label>

          <label class="flex items-center pt-2 pb-4">
            <span class="w-32">Facebook</span>
            <input type="text" size="20" name="url_facebook" class="border border-brightGray-200 px-2 py-1 rounded w-60">
          </label>
        </div>

        <div class="relative py-4 w-1/2">
          <p>アイコン</p>
          <lavel class="absolute bg-bgAddAvatar bg-20 block cursor-pointer h-20 left-1/2 -ml-10 -mt-10 top-1/2 w-20">
            <input type="file" name="avatar" class="cursor-pointer h-20 opacity-0 w-20">
          </lavel>
        </div>
      </div>

      <div class="text-left">
        <label class="flex py-4 w-full">
          <span class="py-1 w-32">自己紹介</span>
          <textarea rows="3" cols="20" name="introduction" class="border border-brightGray-200 px-2 py-1 rounded w-4/5"></textarea>
        </label>
      </div>

      <div class="flex mt-8 relative">
        <a class="bg-brightGray-900 border block border-solid border-brightGray-900 cursor-pointer font-bold mx-auto px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50">保存する</a>
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
