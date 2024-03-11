defmodule BrightWeb.OpenidView do
  use BrightWeb, :view

  alias Boruta.Openid.UserinfoResponse

  def render("jwks.json", %{jwk_keys: jwk_keys}) do
    %{keys: jwk_keys}
  end

  def render("userinfo.json", %{response: response}) do
    UserinfoResponse.payload(response)
  end
end
