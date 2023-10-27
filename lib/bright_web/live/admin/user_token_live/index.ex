defmodule BrightWeb.Admin.UserTokenLive.Index do
  use BrightWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if Bright.Utils.Env.prod?() do
      {:ok, push_navigate(socket, to: "/")}
    else
      socket
      |> assign(:render_header?, false)
      |> assign(:current_user, nil)
      |> assign(:user_2fa_codes, Bright.Repo.all(Bright.Accounts.User2faCodes))
      |> assign(:user_tokens, :ets.lookup(:token, "confirm"))
      |> assign(:team_invite, :ets.lookup(:token, "invite"))
      |> then(&{:ok, &1})
    end
  end
end
