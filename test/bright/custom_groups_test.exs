defmodule Bright.CustomGroupsTest do
  use Bright.DataCase

  alias Bright.CustomGroups

  import Bright.Factory

  setup do
    user = insert(:user)
    %{user: user}
  end

  describe "custom_groups" do
    alias Bright.CustomGroups.CustomGroup

    @invalid_attrs %{name: nil}

    test "list_custom_groups/0 returns all custom_groups", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert CustomGroups.list_custom_groups() == [custom_group]
    end

    test "get_custom_group!/1 returns the custom_group with given id", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert CustomGroups.get_custom_group!(custom_group.id) == custom_group
    end

    test "create_custom_group/1 with valid data creates a custom_group", %{user: user} do
      valid_attrs = %{name: "some name", user_id: user.id}

      assert {:ok, %CustomGroup{} = custom_group} = CustomGroups.create_custom_group(valid_attrs)
      assert custom_group.name == "some name"
    end

    test "create_custom_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CustomGroups.create_custom_group(@invalid_attrs)
    end

    test "update_custom_group/2 with valid data updates the custom_group", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %CustomGroup{} = custom_group} =
               CustomGroups.update_custom_group(custom_group, update_attrs)

      assert custom_group.name == "some updated name"
    end

    test "update_custom_group/2 with invalid data returns error changeset", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)

      assert {:error, %Ecto.Changeset{}} =
               CustomGroups.update_custom_group(custom_group, @invalid_attrs)

      assert custom_group == CustomGroups.get_custom_group!(custom_group.id)
    end

    test "delete_custom_group/1 deletes the custom_group", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert {:ok, %CustomGroup{}} = CustomGroups.delete_custom_group(custom_group)
      assert_raise Ecto.NoResultsError, fn -> CustomGroups.get_custom_group!(custom_group.id) end
    end

    test "change_custom_group/1 returns a custom_group changeset", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert %Ecto.Changeset{} = CustomGroups.change_custom_group(custom_group)
    end
  end
end
