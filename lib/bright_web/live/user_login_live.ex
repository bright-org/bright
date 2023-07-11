defmodule BrightWeb.UserLoginLive do
  use BrightWeb, :live_view

  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
      <h1 class="font-bold text-center text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">ログイン</span>
      </h1>
      <.form
        :let={_f}
        for={@form}
        id="login_form"
        class="flex mt-8 mx-auto relative"
        action={~p"/users/log_in"}
        phx-update="ignore"
      >
        <section class="border-r border-solid border-brightGray-300 flex flex-col mt-5 pr-16 w-2/4">
          <button class="bg-bgGoogle bg-5 bg-left-2.5 bg-no-repeat border border-solid border-black font-bold max-w-xs mt-4 mx-auto px-4 py-2 rounded select-none text-black w-full hover:opacity-50">Google</button>

          <button class="bg-bgGithub bg-5 bg-left-2.5 bg-sns-github bg-no-repeat border border-github border-solid font-bold max-w-xs mt-6 mx-auto px-4 py-2 rounded select-none text-white w-full hover:opacity-50">GitHub</button>

          <button class="bg-bgFacebook bg-5 bg-left-2.5 bg-sns-facebook bg-no-repeat border border-facebook border-solid font-bold max-w-xs mt-6 mx-auto px-4 py-2 rounded select-none text-white w-full hover:opacity-50">Facebook</button>

          <button class="bg-bgTwitter bg-5 bg-left-2.5 bg-sns-twitter bg-no-repeat border border-twitter border-solid font-bold max-w-xs mt-6 mx-auto px-4 py-2 rounded select-none text-white w-full hover:opacity-50">Twitter</button>
        </section>

        <p class="absolute bg-white border border-solid border-brightGray-300 flex h-20 left-2/4 top-2/4 items-center justify-center -ml-10 -mt-10 rounded-full text-brightGray-500 text-xs w-20 z-2">または</p>

        <section class="flex flex-col pt-0 pr-0 pl-16 w-2/4">
          <label for="email" class="mt-4">
            <span class="block font-bold mb-2 text-xs">メールアドレス</span>
            <UserAuthComponents.input field={@form[:email]} id="email" type="email" required />
          </label>

          <label for="password" class="mt-4">
            <span class="block font-bold mb-2 text-xs">パスワード</span>
            <UserAuthComponents.input field={@form[:password]} id="password" type="password" required />
            <.link href={~p"/users/reset_password"} class="block mr-2 mt-1 text-link text-right text-xs underline">パスワードを忘れた方はこちら</.link>
          </label>

          <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold max-w-xs mt-12 px-4 py-2 rounded select-none text-white w-full hover:opacity-50">ログイン</button>
        </section>
      </.form>

      <p class="mt-8 text-link text-center text-xs"><.link navigate={~p"/users/register"} class="underline">ユーザー新規作成はこちら</.link></p>
    """
  end

  def mount(_params, _session, socket) do
    email = live_flash(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
