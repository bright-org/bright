defmodule Bright.Utils.GoogleCloud.Storage do
  @moduledoc """
  GCS API
  """

  @doc """
  Upload a local object to specified path.

  ## Examples

      iex> Bright.CloudStorage.upload_object!("./local_phoenix.png", "phoenix.png")
      :ok

      iex> Bright.CloudStorage.upload_object!("./not_found.png", "phoenix.png")
      ** (Bright.Exceptions.GcsError)
  """
  @spec upload!(local_file_path :: String.t(), storage_path :: String.t()) :: :ok
  def upload!(local_file_path, storage_path) do
    content_type = file_path_to_content_type(local_file_path)

    try do
      {:ok, %GoogleApi.Storage.V1.Model.Object{}} =
        GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
          get_connection!(),
          get_bucket_id!(),
          _upload_type = "multipart",
          %GoogleApi.Storage.V1.Model.Object{name: storage_path, contentType: content_type},
          File.read!(local_file_path)
        )

      :ok
    rescue
      exception in [MatchError, File.Error] ->
        reraise Bright.Exceptions.GcsError, [message: inspect(exception)], __STACKTRACE__
    end
  end

  @doc """
  Delete a object.

  ## Examples

      iex> Bright.CloudStorage.delete_object!("phoenix.png")
      :ok

      iex> Bright.CloudStorage.delete_object!("not_found.png")
      ** (Bright.Exceptions.GcsError)
  """
  @spec delete!(storage_path :: String.t()) :: :ok
  def delete!(storage_path) do
    try do
      {:ok, %Tesla.Env{}} =
        GoogleApi.Storage.V1.Api.Objects.storage_objects_delete(
          get_connection!(),
          get_bucket_id!(),
          storage_path
        )

      :ok
    rescue
      exception in [MatchError] ->
        reraise Bright.Exceptions.GcsError, [message: inspect(exception)], __STACKTRACE__
    end
  end

  @doc """
  Get public url.

  開発環境においては、クライアント端末からの参照を考慮して、localhostを指定している。

  ## Examples

      iex> Bright.CloudStorage.get_object_public_url("phoenix.png")
      "http://localhost:4443/<bucket_id>/phoenix.png"
  """
  def public_url(path) do
    base_url =
      Application.fetch_env!(:google_api_storage, :base_url)
      |> String.replace("//gcs:", "//localhost:")
    bucket_id =
      Application.fetch_env!(:bright, :google_api_storage)
      |> Keyword.fetch!(:bucket_id)

    Path.join([base_url, bucket_id, path])
  end

  @doc """
  Download an object to specified file path.

  ## Examples

      iex> Bright.CloudStorage.download_object!("phoenix.png", "./downloaded.png")
      :ok

      iex> Bright.CloudStorage.download_object!("not_found.png", "./downloaded.png")
      ** (Bright.Exceptions.GcsError)
  """
  @spec download!(storage_path :: String.t(), local_file_path :: String.t()) :: :ok
  def download!(storage_path, local_file_path) do
    try do
      # [{:decode, false}]を渡すため%GoogleApi.Storage.V1.Model.Object{}ではなく、
      # デコードなしの%Tesla.Envが返る。
      # refs) GoogleApi.Storage.V1.Api.Objects.storage_objects_get and
      # GoogleApi.Gax.Response
      {:ok, %Tesla.Env{} = tesla} =
        GoogleApi.Storage.V1.Api.Objects.storage_objects_get(
          get_connection!(),
          get_bucket_id!(),
          storage_path,
          [{:alt, "media"}],
          [{:decode, false}]
        )
      File.write!(local_file_path, tesla.body)

      :ok
    rescue
      exception in [MatchError, File.Error] ->
        reraise Bright.Exceptions.GcsError, [message: inspect(exception)], __STACKTRACE__
    end
  end

  defp file_path_to_content_type(file_path) do
    file_path
    |> Path.extname()
    |> String.trim_leading(".")
    |> String.downcase()
    |> MIME.type()
  end

  @spec get_connection!() :: %Tesla.Client{}
  defp get_connection!() do
    case Application.get_env(:goth, :disabled) do
      true ->
        # dev環境ではローカルにつなぐためgothを用いない。
        GoogleApi.Storage.V1.Connection.new()

      _ ->
        {:ok, token} = Goth.Token.fetch("https://www.googleapis.com/auth/cloud-platform")
        GoogleApi.Storage.V1.Connection.new(token.token)
    end
  end

  @spec get_bucket_id!() :: binary()
  defp get_bucket_id!() do
    bucket_id =
      Application.fetch_env!(:bright, :google_api_storage)
      |> Keyword.fetch!(:bucket_id)

    if is_binary(bucket_id) do
      bucket_id
    else
      raise RuntimeError, "bucket_id is not string."
    end
  end
end
