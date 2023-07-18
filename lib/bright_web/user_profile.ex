defmodule BrightWeb.UserProfile do
  @moduledoc false

  import Plug.Conn
  alias Bright.Repo

  def preload_user_profile(conn, _opts) do
    user = conn.assigns.current_user |> Repo.preload(:user_profile)
    assign(conn, :current_user, user)
  end
end
