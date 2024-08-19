defmodule Bright.Zoho.Crm do
  @moduledoc """
  Zoho CRM との連携を行うモジュール
  """

  require Logger
  alias Bright.Externals
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

  # NOTE: 期限切れでないトークンがあればそれを返し、なければ ZOHO API から取得する
  defp get_access_token_and_api_domain() do
    case get_unexpired_external_token() do
      %Externals.ExternalToken{} = external_token ->
        %{api_domain: external_token.api_domain, access_token: external_token.token}

      # NOTE: トークンがない場合は ZOHO API から取得する
      nil ->
        Auth.new()
        |> Auth.auth()
        |> handle_auth()
    end
  end

  defp get_unexpired_external_token() do
    case Externals.get_external_token(%{token_type: :ZOHO_CRM}) do
      %Externals.ExternalToken{} = external_token ->
        case Externals.token_expired?(external_token) do
          true ->
            nil

          false ->
            external_token
        end

      nil ->
        nil
    end
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
        # NOTE: 期限内で使いまわせるようにトークンをDBに保存する
        create_or_update_access_token(access_token, api_domain, expires_in)
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

  defp create_or_update_access_token(access_token, api_domain, expires_in) do
    expired_at = NaiveDateTime.utc_now() |> NaiveDateTime.add(expires_in, :second)

    case Externals.get_external_token(%{token_type: :ZOHO_CRM}) do
      %Externals.ExternalToken{} = external_token ->
        Externals.update_external_token(external_token, %{
          token: access_token,
          api_domain: api_domain,
          expired_at: expired_at
        })

      nil ->
        Externals.create_external_token(%{
          token_type: :ZOHO_CRM,
          token: access_token,
          api_domain: api_domain,
          expired_at: expired_at
        })
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

  field9 は「連携元」項目
  """
  def build_create_contact_payload(%{name: name, email: email}) do
    %{"data" => [%{"Last_Name" => name, "Email" => email, "field9" => "Brightユーザー"}]}
  end
end
