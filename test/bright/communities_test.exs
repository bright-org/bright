defmodule Bright.CommunitiesTest do
  use Bright.DataCase

  alias Bright.Communities

  import Bright.Factory

  describe "communities" do
    alias Bright.Communities.Community

    @invalid_attrs %{name: nil, user_id: nil, community_id: nil, participation: nil}

    test "list_communities/0 returns all communities" do
      community = insert(:community)

      assert Communities.list_communities() == [community]
    end

    test "get_community!/1 returns the community with given id" do
      community = insert(:community)

      assert Communities.get_community!(community.id) == community
    end

    test "create_community/1 with valid data creates a community" do
      valid_attrs = %{
        name: "some name"
      }

      assert {:ok, %Community{} = community} = Communities.create_community(valid_attrs)
      assert community.name == "some name"
    end

    test "create_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communities.create_community(@invalid_attrs)
    end

    test "update_community/2 with valid data updates the community" do
      community = insert(:community)

      update_attrs = %{
        name: "some updated name"
      }

      assert {:ok, %Community{} = community} =
               Communities.update_community(community, update_attrs)

      assert community.name == "some updated name"
    end

    test "update_community/2 with invalid data returns error changeset" do
      community = insert(:community)
      assert {:error, %Ecto.Changeset{}} = Communities.update_community(community, @invalid_attrs)

      assert community == Communities.get_community!(community.id)
    end

    test "delete_community/1 deletes the community" do
      community = insert(:community)
      assert {:ok, %Community{}} = Communities.delete_community(community)
      assert_raise Ecto.NoResultsError, fn -> Communities.get_community!(community.id) end
    end

    test "change_community/1 returns a community changeset" do
      community = insert(:community)
      assert %Ecto.Changeset{} = Communities.change_community(community)
    end
  end
end
