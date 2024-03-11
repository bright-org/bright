defmodule BrightWeb.Openid.UserinfoController do
  @behaviour Boruta.Openid.UserinfoApplication

  use BrightWeb, :controller

  alias Boruta.Openid.UserinfoResponse

  alias BrightWeb.OpenidView

  def openid_module, do: Application.get_env(:bright, :openid_module, Boruta.Openid)

  def userinfo(conn, _params) do
    openid_module().userinfo(conn, __MODULE__)
  end

  @impl Boruta.Openid.UserinfoApplication
  def userinfo_fetched(conn, userinfo_response) do
    conn
    |> put_view(OpenidView)
    |> put_resp_header("content-type", UserinfoResponse.content_type(userinfo_response))
    |> render("userinfo.json", response: userinfo_response)
  end

  @impl Boruta.Openid.UserinfoApplication
  def unauthorized(conn, error) do
    conn
    |> put_resp_header(
      "www-authenticate",
      "error=\"#{error.error}\", error_description=\"#{error.error_description}\""
    )
    |> send_resp(:unauthorized, "")
  end
end
