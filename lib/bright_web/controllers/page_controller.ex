defmodule BrightWeb.PageController do
  use BrightWeb, :controller

  def home(conn, _params) do
    if Bright.Utils.Env.prod?() do
      redirect(conn, to: ~p"/mypage")
    else
      render(conn, :home, layout: false)
    end
  end
end
