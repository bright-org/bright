defmodule Bright.Zoho.Crm.Client do
  @moduledoc """
  Zoho CRM の API クライアント
  """

  @doc """
  クライアントを生成する

  ## Examples

      iex> Bright.Zoho.Crm.Client.new(%{api_domain: "https://www.zohoapis.jp", access_token: "xxxxx"})
      %Tesla.Client{}
  """
  def new(%{api_domain: api_domain, access_token: access_token}) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "#{api_domain}/crm/v6"},
      {Tesla.Middleware.Headers, [{"authorization", "Zoho-oauthtoken #{access_token}"}]},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  @doc """
  「連絡先」を1件作成する
  """
  def create_contact(client, data) do
    client |> Tesla.post("/Contacts", data)
  end
end
