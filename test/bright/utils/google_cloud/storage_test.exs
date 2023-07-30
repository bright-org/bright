defmodule Bright.Utils.GoogleCloud.StorageTest do
  use Bright.DataCase, async: false

  alias Bright.Utils.GoogleCloud.Storage

  describe "upload!" do
    setup do
      sample_file_path = Path.join([test_support_dir(), "images", "sample.svg"])

      %{
        local_file_path: sample_file_path,
        storage_path: "image.svg"
      }
    end

    test "returns :ok", %{
      local_file_path: local_file_path,
      storage_path: storage_path
    } do
      assert :ok = Storage.upload!(local_file_path, storage_path)
    end

    test "raises Bright.Exceptions.GcsError by MatchError", %{
      local_file_path: _local_file_path,
      storage_path: storage_path
    } do
      local_file_path = "not_existing.svg"

      assert_raise Bright.Exceptions.GcsError, fn ->
        Storage.upload!(local_file_path, storage_path)
      end
    end
  end

  describe "delete!" do
    setup do
      sample_file_path = Path.join([test_support_dir(), "images", "sample.svg"])
      storage_path = "image.svg"
      Storage.upload!(sample_file_path, storage_path)

      %{storage_path: storage_path}
    end

    test "returns :ok", %{
      storage_path: storage_path
    } do
      assert :ok = Storage.delete!(storage_path)
    end

    test "raises Bright.Exceptions.GcsError by MatchError", %{
      storage_path: _storage_path
    } do
      storage_path = "not_existing.svg"

      assert_raise Bright.Exceptions.GcsError, fn ->
        Storage.delete!(storage_path)
      end
    end
  end

  describe "public_url" do
    setup do
      %{storage_path: "image.png"}
    end

    test "returns public url on gcs", %{
      storage_path: storage_path
    } do
      public_base_url =
        Application.fetch_env!(:bright, :google_api_storage)
        |> Keyword.get(:public_base_url)

      expected = "#{public_base_url}/bright_storage_local_test/image.png"
      assert ^expected = Storage.public_url(storage_path)
    end
  end
end
