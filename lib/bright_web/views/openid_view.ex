defmodule BrightWeb.OpenidView do
  def render("jwks.json", %{jwk_keys: jwk_keys}) do
    %{keys: jwk_keys}
  end

  def render("userinfo.json", %{response: response}) do
    response.userinfo
  end
end
