defmodule Bright.CommunitiesTest do
  use Bright.DataCase

  alias Bright.Communities

  import Bright.Factory

  describe "communities" do
    alias Bright.Communities.Community

    @invalid_attrs %{name: nil, user_id: nil, community_id: nil, participation: nil}

    test "list_communities/0 returns all communities" do
      community = insert(:community)

      assert Communities.list_communities() |> Repo.preload([:user, community: [:from_user]]) == [
               community
             ]
    end

    test "get_community!/1 returns the community with given id" do
      community = insert(:community)

      assert Communities.get_community!(community.id)
             |> Repo.preload([:user, community: [:from_user]]) == community
    end

    test "create_community/1 with valid data creates a community" do
      user = insert(:user)
      notification_community = insert(:notification_community)

      valid_attrs = %{
        name: "some name",
        user_id: user.id,
        community_id: notification_community.id,
        participation: true
      }

      assert {:ok, %Community{} = community} = Communities.create_community(valid_attrs)
      assert community.name == "some name"
      assert community.user_id == user.id
      assert community.community_id == notification_community.id
      assert community.participation == true
    end

    test "create_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Communities.create_community(@invalid_attrs)
    end

    test "update_community/2 with valid data updates the community" do
      community = insert(:community)
      user = insert(:user)
      notification_community = insert(:notification_community)

      update_attrs = %{
        name: "some updated name",
        user_id: user.id,
        community_id: notification_community.id,
        participation: false
      }

      assert {:ok, %Community{} = community} =
               Communities.update_community(community, update_attrs)

      assert community.name == "some updated name"
      assert community.user_id == user.id
      assert community.community_id == notification_community.id
      assert community.participation == false
    end

    test "update_community/2 with invalid data returns error changeset" do
      community = insert(:community)
      assert {:error, %Ecto.Changeset{}} = Communities.update_community(community, @invalid_attrs)

      assert community ==
               Communities.get_community!(community.id)
               |> Repo.preload([:user, community: [:from_user]])
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
