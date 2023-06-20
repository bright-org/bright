defmodule Bright.GoogleCloud do
  @moduledoc """
  Google Cloudを対象とするAPI
  """

  alias Bright.GoogleCloud.Storage

  @doc """
  Upload a local object to GCS(Google Cloud Storage) specified file path.

  ## Examples

      iex> Bright.GoogleCloud.upload_storage!("./local_phoenix.png", "phoenix.png")
      :ok

      iex> Bright.GoogleCloud.upload_storage!("./not_found.png", "phoenix.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate upload_storage!(local_file_path, storage_path), to: Storage, as: :upload!

  @doc """
  Delete a GCS(Google Cloud Storage) object.

  ## Examples

      iex> Bright.GoogleCloud.delete_storage!("phoenix.png")
      :ok

      iex> Bright.GoogleCloud.delete_storage!("not_found.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate delete_storage!(storage_path), to: Storage, as: :delete!

  @doc """
  Get a GCS(Google Cloud Storage) object public url.

  ## Examples

      iex> Bright.GoogleCloud.get_storage_public_url("phoenix.png")
      "http://localhost:4443/<bucket_id>/phoenix.png"
  """
  defdelegate get_storage_public_url(storage_path), to: Storage, as: :public_url

  @doc """
  Download an object of GCS(Google Cloud Storage) to specified file path.

  ## Examples

      iex> Bright.GoogleCloud.download_storage!("phoenix.png", "./downloaded.png")
      :ok

      iex> Bright.GoogleCloud.download_storage!("not_found.png", "./downloaded.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate download_storage!(storage_path, local_file_path), to: Storage, as: :download!
end
