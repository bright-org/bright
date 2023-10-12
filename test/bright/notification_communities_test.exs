defmodule Bright.NotificationCommunitiesTest do
  use Bright.DataCase

  alias Bright.NotificationCommunities

  import Bright.Factory

  describe "notification_communities" do
    alias Bright.Notifications.NotificationCommunity

    @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

    test "list_notification_communities/0 returns all notification_communities" do
      notification_community = insert(:notification_community)

      assert NotificationCommunities.list_notification_communities() |> Repo.preload(:from_user) ==
               [notification_community]
    end

    test "get_notification_community!/1 returns the notification_community with given id" do
      notification_community = insert(:notification_community)

      assert NotificationCommunities.get_notification_community!(notification_community.id)
             |> Repo.preload(:from_user) == notification_community
    end

    test "create_notification_community/1 with valid data creates a notification_community" do
      from_user = insert(:user)

      valid_attrs = %{message: "some message", from_user_id: from_user.id, detail: "some detail"}

      assert {:ok, %NotificationCommunity{} = notification_community} =
               NotificationCommunities.create_notification_community(valid_attrs)

      assert notification_community.message == "some message"
      assert notification_community.from_user_id == from_user.id
      assert notification_community.detail == "some detail"
    end

    test "create_notification_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               NotificationCommunities.create_notification_community(@invalid_attrs)
    end

    test "update_notification_community/2 with valid data updates the notification_community" do
      notification_community = insert(:notification_community)
      from_user = insert(:user)

      update_attrs = %{
        message: "some updated message",
        from_user_id: from_user.id,
        detail: "some updated detail"
      }

      assert {:ok, %NotificationCommunity{} = notification_community} =
               NotificationCommunities.update_notification_community(
                 notification_community,
                 update_attrs
               )

      assert notification_community.message == "some updated message"
      assert notification_community.from_user_id == from_user.id
      assert notification_community.detail == "some updated detail"
    end

    test "update_notification_community/2 with invalid data returns error changeset" do
      notification_community = insert(:notification_community)

      assert {:error, %Ecto.Changeset{}} =
               NotificationCommunities.update_notification_community(
                 notification_community,
                 @invalid_attrs
               )

      assert notification_community ==
               NotificationCommunities.get_notification_community!(notification_community.id)
               |> Repo.preload(:from_user)
    end

    test "delete_notification_community/1 deletes the notification_community" do
      notification_community = insert(:notification_community)

      assert {:ok, %NotificationCommunity{}} =
               NotificationCommunities.delete_notification_community(notification_community)

      assert_raise Ecto.NoResultsError, fn ->
        NotificationCommunities.get_notification_community!(notification_community.id)
      end
    end

    test "change_notification_community/1 returns a notification_community changeset" do
      notification_community = insert(:notification_community)

      assert %Ecto.Changeset{} =
               NotificationCommunities.change_notification_community(notification_community)
    end
  end
end
