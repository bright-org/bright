defmodule Bright.TestStorage do
  @moduledoc """
  GCS API for test
  TODO: getをStorageに生やしたため削除可能になる見込み
  """

  def get(storage_path) do
    GoogleApi.Storage.V1.Api.Objects.storage_objects_get(
      get_connection!(),
      get_bucket_name!(),
      storage_path
    )
  end

  defp get_connection! do
    GoogleApi.Storage.V1.Connection.new()
  end

  @spec get_bucket_name!() :: binary()
  defp get_bucket_name! do
    Application.fetch_env!(:bright, :google_api_storage)
    |> Keyword.fetch!(:bucket_name)
  end
end
