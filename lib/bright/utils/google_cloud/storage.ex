defmodule Bright.Utils.GoogleCloud.Storage do
  @moduledoc """
  GCS API
  """

  @doc """
  Upload a local object to specified path.

  ## Examples

      iex> Bright.Utils.GoogleCloud.Storage.upload!("./local_phoenix.png", "phoenix.png")
      :ok

      iex> Bright.Utils.GoogleCloud.Storage.upload!("./not_found.png", "phoenix.png")
      ** (Bright.Exceptions.GcsError)
  """
  @spec upload!(local_file_path :: String.t(), storage_path :: String.t()) :: :ok
  def upload!(local_file_path, storage_path) do
    content_type = file_path_to_content_type(local_file_path)

    try do
      {:ok, %GoogleApi.Storage.V1.Model.Object{}} =
        GoogleApi.Storage.V1.Api.Objects.storage_objects_insert_iodata(
          get_connection!(),
          get_bucket_name!(),
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

      iex> Bright.Utils.GoogleCloud.Storage.delete!("phoenix.png")
      :ok

      iex> Bright.Utils.GoogleCloud.Storage.delete!("not_found.png")
      ** (Bright.Exceptions.GcsError)
  """
  @spec delete!(storage_path :: String.t()) :: :ok
  def delete!(storage_path) do
    try do
      {:ok, %Tesla.Env{}} =
        GoogleApi.Storage.V1.Api.Objects.storage_objects_delete(
          get_connection!(),
          get_bucket_name!(),
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

  ## Examples

      iex> Bright.Utils.GoogleCloud.Storage.public_url("phoenix.png")
      "https://storage.googleapis.com/<get_bucket_name>/phoenix.png"
  """
  def public_url(path) do
    public_base_url =
      get_public_base_url() || Application.fetch_env!(:google_api_storage, :base_url)

    Path.join([public_base_url, get_bucket_name!(), path])
  end

  defp file_path_to_content_type(file_path) do
    file_path
    |> Path.extname()
    |> String.trim_leading(".")
    |> String.downcase()
    |> MIME.type()
  end

  @spec get_connection!() :: Tesla.Client.t()
  defp get_connection! do
    case Application.get_env(:goth, :disabled) do
      true ->
        # ローカル環境ではローカル環境の GCS に接続するため goth を用いない。
        GoogleApi.Storage.V1.Connection.new()

      _ ->
        Goth.fetch!(Bright.Goth)
        |> GoogleApi.Storage.V1.Connection.new()
    end
  end

  @spec get_bucket_name!() :: binary()
  defp get_bucket_name! do
    Application.fetch_env!(:bright, :google_api_storage)
    |> Keyword.fetch!(:bucket_name)
  end

  defp get_public_base_url do
    Application.fetch_env!(:bright, :google_api_storage)
    |> Keyword.get(:public_base_url)
  end
end
