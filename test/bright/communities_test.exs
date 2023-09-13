defmodule Bright.CommunitiesTest do
  use Bright.DataCase

  alias Bright.Communities

  describe "communities" do
    alias Bright.Communities.Community

    import Bright.CommunitiesFixtures

    @invalid_attrs %{name: nil, user_id: nil, community_id: nil, participation: nil}

    test "list_communities/0 returns all communities" do
      community = community_fixture()
      assert Communities.list_communities() == [community]
    end

    test "get_community!/1 returns the community with given id" do
      community = community_fixture()
      assert Communities.get_community!(community.id) == community
    end

    test "create_community/1 with valid data creates a community" do
      valid_attrs = %{name: "some name", user_id: "7488a646-e31f-11e4-aace-600308960662", community_id: "7488a646-e31f-11e4-aace-600308960662", participation: true}

      assert {:ok, %Community{} = community} = Communities.create_community(valid_attrs)
      assert community.name == "some name"
      assert community.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert community.community_id == "7488a646-e31f-11e4-aace-600308960662"
      assert community.participation == true
    end

    test "create_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communities.create_community(@invalid_attrs)
    end

    test "update_community/2 with valid data updates the community" do
      community = community_fixture()
      update_attrs = %{name: "some updated name", user_id: "7488a646-e31f-11e4-aace-600308960668", community_id: "7488a646-e31f-11e4-aace-600308960668", participation: false}

      assert {:ok, %Community{} = community} = Communities.update_community(community, update_attrs)
      assert community.name == "some updated name"
      assert community.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert community.community_id == "7488a646-e31f-11e4-aace-600308960668"
      assert community.participation == false
    end

    test "update_community/2 with invalid data returns error changeset" do
      community = community_fixture()
      assert {:error, %Ecto.Changeset{}} = Communities.update_community(community, @invalid_attrs)
      assert community == Communities.get_community!(community.id)
    end

    test "delete_community/1 deletes the community" do
      community = community_fixture()
      assert {:ok, %Community{}} = Communities.delete_community(community)
      assert_raise Ecto.NoResultsError, fn -> Communities.get_community!(community.id) end
    end

    test "change_community/1 returns a community changeset" do
      community = community_fixture()
      assert %Ecto.Changeset{} = Communities.change_community(community)
    end
  end
end
