defmodule BrightWeb.UserForgotPasswordLive do
  use BrightWeb, :live_view

  alias Bright.Accounts
  alias BrightWeb.UserAuthComponents

  def render(assigns) do
    ~H"""
      <h1 class="font-bold text-center text-3xl">
        <span class="before:bg-bgGem before:bg-9 before:bg-left before:bg-no-repeat before:content-[''] before:h-9 before:inline-block before:relative before:top-[5px] before:w-9">パスワードを忘れた方へ</span>
      </h1>

      <p class="mt-8 mx-auto text-sm w-fit">パスワードをリセットするリンクをメールに送ります。<br>登録しているユーザーのメールアドレスを入力してください。</p>

      <.form
        :let={_f}
        for={@form}
        id="reset_password_form"
        class="flex mt-8 mx-auto relative"
        phx-submit="send_email"
      >
        <section class="flex flex-col mx-auto">
          <label for="email" class="mt-4">
            <span class="block font-bold mb-2 text-xs">メールアドレス</span>
            <UserAuthComponents.input field={@form[:email]} id="email" type="email" required />
          </label>

          <button class="bg-brightGray-900 border border-solid border-brightGray-900 font-bold mt-8 max-w-xs px-4 py-2 rounded select-none text-white w-full hover:opacity-50">パスワードリセット用リンクを送信</button>

          <.link href={~p"/users/log_in"} class="text-center bg-white border border-solid border-black font-bold mt-16 mx-auto px-4 py-2 rounded select-none text-black w-40 hover:opacity-50">
            戻る
          </.link>
        </section>
      </.form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    {:noreply, socket |> redirect(to: ~p"/users/send_reset_password_url")}
  end
end
