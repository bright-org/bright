defmodule Bright.Zoho.Crm do
  @moduledoc """
  Zoho CRM との連携を行うモジュール
  """

  require Logger
  alias Bright.Zoho.Auth
  alias Bright.Zoho.Crm.Client

  defp build_client do
    get_access_token_and_api_domain()
    |> case do
      %{api_domain: _api_domain, access_token: _access_token} = res ->
        Client.new(res)

      _ ->
        :error
    end
  end

  # TODO: まず DB に問い合わせる。なければ Zoho に問い合わせる。
  defp get_access_token_and_api_domain() do
    Auth.new()
    |> Auth.auth()
    |> handle_auth()
  end

  defp handle_auth(result) do
    case result do
      {:ok, %Tesla.Env{body: %{"error" => error_message}}} ->
        Logger.error("Failed to Zoho Auth: #{error_message}")
        :error

      {:ok,
       %Tesla.Env{
         status: status,
         body: %{
           "api_domain" => api_domain,
           "access_token" => access_token,
           "expires_in" => expires_in
         }
       }}
      when status in 200..299 ->
        # TODO: expires_in 使って期限を計算し、保存する
        %{api_domain: api_domain, access_token: access_token}

      # NOTE: 200 系以外はエラーとして扱う
      {:ok, response} ->
        Logger.error("Failed to Zoho Auth: #{inspect(Map.get(response, :body))}")
        :error

      {:error, error} ->
        Logger.error("Failed to Zoho Auth: #{inspect(error)}")
        :error
    end
  end

  @doc """
  連絡先を作成する

  ## Examples

      iex> build_create_contact_payload(%{name: "koyo", email: "koyo@example.com"}) |> Bright.Zoho.Crm.create_contact()
      {:ok, %Tesla.Env{status: 201}}

      iex> build_create_contact_payload(%{name: "koyo", email: "koyo@example.com"}) |> Bright.Zoho.Crm.create_contact()
      :error
  """
  def create_contact(payload) do
    build_client()
    |> case do
      %Tesla.Client{} = client ->
        Client.create_contact(client, payload) |> handle_create_contact()

      _ ->
        :error
    end
  end

  defp handle_create_contact(result) do
    case result do
      {:ok, %Tesla.Env{status: status} = response} when status in 200..299 ->
        {:ok, response}

      # NOTE: 200 系以外はエラーとして扱う
      {:ok, response} ->
        Logger.error("Failed to create_contact: #{inspect(Map.get(response, :body))}")
        :error

      {:error, error} ->
        Logger.error("Failed to create_contact: #{inspect(error)}")
        :error
    end
  end

  @doc """
  連絡先作成用のペイロードを生成する
  """
  def build_create_contact_payload(%{name: name, email: email}) do
    %{"data" => [%{"Last_Name" => name, "Email" => email}]}
  end
end
