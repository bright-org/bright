defmodule BrightWeb.UserFinishRegistrationLive do
  use BrightWeb, :live_view
  alias BrightWeb.UserAuthComponents

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <UserAuthComponents.header>仮登録完了</UserAuthComponents.header>

    <UserAuthComponents.description>
      仮登録完了メールを送信しましたので<br />メールの内容に従って本登録の手続き<br />を進めてください。
    </UserAuthComponents.description>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
