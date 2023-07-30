defmodule BrightWeb.UserSettingsLive.AuthSettingComponent do
  use BrightWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <li class="block">
      <div class="border-b border-brightGray-200 flex flex-wrap" id="mail_section">
        <div class="border-b border-brightGray-200 mb-4 w-full">
          <label class="flex items-center py-4">
            <span class="w-44">メールアドレス</span>
            <input type="text" size="20" name="mail" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>
        </div>

        <div class="w-1/2" id="sub_mail_0">
          <label class="flex items-center pb-4">
            <span class="flex items-center justify-between w-44">サブアドレス <i class="bg-brightGreen-900 block border border-brightGreen-900 cursor-pointer h-4 indent-40 mr-2 mt-px overflow-hidden relative rounded-full w-4 before:top-1/2 before:left-1/2 before:-ml-1 before:-mt-px before:content-[''] before:block before:absolute before:w-2 before:h-0.5 before:bg-white after:top-1/2 after:left-1/2 after:-ml-1 after:-mt-px after:content-[''] after:block after:absolute after:w-2 after:h-0.5 after:bg-white after:rotate-90 hover:opacity-50">追加</i></span>
            <input type="text" size="20" name="sub_mail_0" class="border border-brightGray-200 px-2 py-1  rounded w-48">
          </label>
        </div>
      </div>

      <div class="mb-4 w-full">
        <label class="flex items-center pb-2 pt-4">
          <span class="w-44">現在のパスワード</span>
          <input type="password" size="20" name="pass" class="border border-brightGray-200 px-2 py-1  rounded w-48">
        </label>
      </div>

      <div class="mb-2 w-full">
        <label class="flex items-center">
          <span class="w-44">新しいパスワード</span>
          <input type="password" size="20" name="pass" class="border border-brightGray-200 px-2 py-1  rounded w-48">
        </label>
      </div>

      <div class="w-full">
        <label class="flex items-center pb-4">
          <span class="w-44">新しいパスワード（確認）</span>
          <input type="password" size="20" name="pass" class="border border-brightGray-200 px-2 py-1  rounded w-48">
        </label>
      </div>

      <div class="flex mt-8 mx-auto w-fit">
        <a class="bg-brightGray-900 border border-solid border-brightGray-900 cursor-pointer font-bold px-4 py-2 rounded select-none text-center text-white w-80 hover:opacity-50">保存する</a>
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
