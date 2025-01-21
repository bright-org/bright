defmodule Bright.CareerGroupsTest do
  use Bright.DataCase

  alias Bright.CareerGroups

  describe "career_groups" do
    alias Bright.CareerGroups.CareerGroup

    @invalid_attrs %{name: nil, type: :engineer, position: nil}

    test "list_career_groups/0 returns all career_groups" do
      career_group = insert(:career_group)
      assert CareerGroups.list_career_groups() == [career_group]
    end

    test "get_career_group!/1 returns the career_group with given id" do
      career_group = insert(:career_group)
      assert CareerGroups.get_career_group!(career_group.id) == career_group
    end

    test "create_career_group/1 with valid data creates a career_group" do
      valid_attrs = %{
        name: "some name",
        type: :engineer,
        position: 1
      }

      assert {:ok, %CareerGroup{} = career_group} = CareerGroups.create_career_group(valid_attrs)
      assert career_group.name == "some name"
      assert career_group.type == :engineer
      assert career_group.position == 1
    end

    test "create_career_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CareerGroups.create_career_group(@invalid_attrs)
    end

    test "update_career_group/2 with valid data updates the career_group" do
      career_group = insert(:career_group)

      update_attrs = %{
        name: "some updated name",
        type: :medical,
        position: 2
      }

      assert {:ok, %CareerGroup{} = career_group} =
               CareerGroups.update_career_group(career_group, update_attrs)

      assert career_group.name == "some updated name"
      assert career_group.type == :medical
      assert career_group.position == 2
    end

    test "update_career_group/2 with invalid data returns error changeset" do
      career_group = insert(:career_group)

      assert {:error, %Ecto.Changeset{}} =
               CareerGroups.update_career_group(career_group, @invalid_attrs)

      assert career_group == CareerGroups.get_career_group!(career_group.id)
    end

    test "delete_career_group/1 deletes the career_group" do
      career_group = insert(:career_group)
      assert {:ok, %CareerGroup{}} = CareerGroups.delete_career_group(career_group)
      assert_raise Ecto.NoResultsError, fn -> CareerGroups.get_career_group!(career_group.id) end
    end

    test "change_career_group/1 returns a career_group changeset" do
      career_group = insert(:career_group)
      assert %Ecto.Changeset{} = CareerGroups.change_career_group(career_group)
    end
  end
end
