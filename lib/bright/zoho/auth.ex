defmodule Bright.Zoho.Auth do
  @moduledoc """
  Zoho の認証を行うモジュール
  """

  @doc """
  認証用のクライアントを生成する

  ## Examples

      iex> Bright.Zoho.Auth.new()
      %Tesla.Client{}
  """
  def new do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://accounts.zoho.jp"},
      Tesla.Middleware.JSON
    ]

    Tesla.client(middleware)
  end

  @doc """
  oauth で認証を行う

  ## Examples

      iex> Bright.Zoho.Auth.new() |> Bright.Zoho.Auth.auth()
      {:ok, %Tesla.Env{body: %{"access_token" => "xxxxx", "expires_in" => 3600, "api_domain" => "https://www.zohoapis.jp"}}}

      iex> Bright.Zoho.Auth.new() |> Bright.Zoho.Auth.auth()
      {:ok, %Tesla.Env{body: %{"error" => "invalid_client"}}}

      iex> Bright.Zoho.Auth.new() |> Bright.Zoho.Auth.auth()
      {:error, :econnrefused}
  """
  def auth(client) do
    client
    |> Tesla.post("/oauth/v2/token", %{},
      query: [
        grant_type: "client_credentials",
        client_id: System.get_env("ZOHO_CLIENT_ID"),
        client_secret: System.get_env("ZOHO_CLIENT_SECRET"),
        scope: "ZohoCRM.modules.ALL",
        soid: System.get_env("ZOHO_CRM_ZSOID")
      ]
    )
  end
end
