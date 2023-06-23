defmodule Bright.Utils.GoogleCloud.StorageTest do
  use ExUnit.Case

  import Mock

  alias Bright.Utils.GoogleCloud.Storage

  describe "upload!" do
    setup %{tmp_dir: tmp_dir} do
      tmp_file_path = Path.join(tmp_dir, "test.txt")
      :ok = File.touch(tmp_file_path)

      %{
        local_file_path: tmp_file_path,
        storage_path: "dummy_storage_path"
      }
    end

    @tag :tmp_dir
    test "returns :ok", %{
      local_file_path: local_file_path,
      storage_path: storage_path
    } do
      with_mock GoogleApi.Storage.V1.Api.Objects,
        storage_objects_insert_iodata: fn _, _, _, _, _ ->
          {:ok, %GoogleApi.Storage.V1.Model.Object{}}
        end do
        assert :ok = Storage.upload!(local_file_path, storage_path)
      end
    end

    @tag :tmp_dir
    test "raises Bright.Exceptions.GcsError by MatchError", %{
      local_file_path: local_file_path,
      storage_path: storage_path
    } do
      with_mock GoogleApi.Storage.V1.Api.Objects,
        storage_objects_insert_iodata: fn _, _, _, _, _ ->
          {:error, %Tesla.Env{}}
        end do
        assert_raise Bright.Exceptions.GcsError, fn ->
          Storage.upload!(local_file_path, storage_path)
        end
      end
    end
  end

  describe "delete!" do
    setup do
      %{storage_path: "dummy_storage_path"}
    end

    test "returns :ok", %{
      storage_path: storage_path
    } do
      with_mock GoogleApi.Storage.V1.Api.Objects,
        storage_objects_delete: fn _, _, _ ->
          {:ok, %Tesla.Env{}}
        end do
        assert :ok = Storage.delete!(storage_path)
      end
    end

    test "raises Bright.Exceptions.GcsError by MatchError", %{
      storage_path: storage_path
    } do
      with_mock GoogleApi.Storage.V1.Api.Objects,
        storage_objects_delete: fn _, _, _ ->
          {:error, %Tesla.Env{}}
        end do
        assert_raise Bright.Exceptions.GcsError, fn ->
          Storage.delete!(storage_path)
        end
      end
    end
  end

  describe "public_url" do
    setup do
      %{storage_path: "dummy_storage_path"}
    end

    test "returns public url on gcs", %{
      storage_path: storage_path
    } do
      expected = "http://localhost:4443/test-bucket/dummy_storage_path"
      assert ^expected = Storage.public_url(storage_path)
    end
  end
end
