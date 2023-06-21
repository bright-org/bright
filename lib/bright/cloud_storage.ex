defmodule Bright.CloudStorage do
  @moduledoc """
  クラウド上のストレージを扱うAPI
  """

  alias Bright.CloudStorage.GoogleCloud, as: Storage

  @doc """
  Upload local object.

  ## Examples

      iex> Bright.CloudStorage.upload_object!("./local_phoenix.png", "phoenix.png")
      :ok

      iex> Bright.CloudStorage.upload_object!("./not_found.png", "phoenix.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate upload_object!(local_file_path, storage_path), to: Storage, as: :upload!

  @doc """
  Delete object.

  ## Examples

      iex> Bright.CloudStorage.delete_object!("phoenix.png")
      :ok

      iex> Bright.CloudStorage.delete_object!("not_found.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate delete_object!(storage_path), to: Storage, as: :delete!

  @doc """
  Get object public url.

  ## Examples

      iex> Bright.CloudStorage.get_object_public_url("phoenix.png")
      "http://localhost:4443/<bucket_id>/phoenix.png"
  """
  defdelegate get_object_public_url(storage_path), to: Storage, as: :public_url

  @doc """
  Download object.

  ## Examples

      iex> Bright.CloudStorage.download_object!("phoenix.png", "./downloaded.png")
      :ok

      iex> Bright.CloudStorage.download_object!("not_found.png", "./downloaded.png")
      ** (Bright.Exceptions.GcsError)
  """
  defdelegate download_object!(storage_path, local_file_path), to: Storage, as: :download!
end
