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

  @doc """
  「連絡先」を email から検索する
  """
  def search_contact_by_email(client, email) do
    client |> Tesla.get("/Contacts/search?email=#{email}")
  end

  @doc """
  「連絡先」を更新する
  """
  def update_contact(client, contact_id, data) do
    client |> Tesla.put("/Contacts/#{contact_id}", data)
  end
end
