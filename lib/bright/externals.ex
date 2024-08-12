defmodule Bright.Externals do
  @moduledoc """
  外部サービスとの連携を行うモジュール
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Externals.ExternalToken

  @valid_token_types ExternalToken.token_types()

  @doc """
  Gets a single external_token by token_type.

  ## Examples

      iex> get_external_token(%{token_type: :ZOHO_CRM})
      %ExternalToken{}

      iex> get_external_token(%{token_type: :ZOHO_CRM})
      nil

  """
  def get_external_token(%{token_type: token_type}) when token_type in @valid_token_types do
    Repo.get_by(ExternalToken, token_type: token_type)
  end

  @doc """
  Creates a external_token.

  ## Examples

      iex> create_external_token(%{field: value})
      {:ok, %ExternalToken{}}

      iex> create_external_token(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_external_token(attrs \\ %{}) do
    %ExternalToken{}
    |> ExternalToken.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a external_token.

  ## Examples

      iex> update_external_token(external_token, %{field: new_value})
      {:ok, %ExternalToken{}}

      iex> update_external_token(external_token, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_external_token(%ExternalToken{} = external_token, attrs) do
    external_token
    |> ExternalToken.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  取得したトークンが期限切れかどうかを判定する。
  判定後に使用する際、期限切れになることを防ぐため、現在時刻 + 一定秒数を基準に判定する。
  第二引数で設定、単位は秒、デフォルト300秒。

  ## Examples

      iex> token_expired?(%ExternalToken{})
      true

      iex> token_expired?(%ExternalToken{}, 60)
      true

      iex> token_expired?(%ExternalToken{})
      false


  """
  def token_expired?(%ExternalToken{} = external_token, expiry_margin_sec \\ 300) do
    base_time = NaiveDateTime.utc_now() |> NaiveDateTime.add(expiry_margin_sec, :second)

    NaiveDateTime.before?(external_token.expired_at, base_time)
  end
end
