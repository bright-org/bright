defmodule Bright.NotificationCommunitiesTest do
  use Bright.DataCase

  alias Bright.Notifications

  import Bright.Factory

  describe "notification_communities" do
    alias Bright.Notifications.NotificationCommunity

    import Bright.NotificationsFixtures

    @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

    test "list_notification_communities/0 returns all notification_communities" do
      notification_community = notification_community_fixture()
      assert Notifications.list_notification_communities() == [notification_community]
    end

    test "get_notification_community!/1 returns the notification_community with given id" do
      notification_community = notification_community_fixture()
      assert Notifications.get_notification_community!(notification_community.id) == notification_community
    end

    test "create_notification_community/1 with valid data creates a notification_community" do
      valid_attrs = %{message: "some message", from_user_id: "7488a646-e31f-11e4-aace-600308960662", detail: "some detail"}

      assert {:ok, %NotificationCommunity{} = notification_community} = Notifications.create_notification_community(valid_attrs)
      assert notification_community.message == "some message"
      assert notification_community.from_user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert notification_community.detail == "some detail"
    end

    test "create_notification_community/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification_community(@invalid_attrs)
    end

    test "update_notification_community/2 with valid data updates the notification_community" do
      notification_community = notification_community_fixture()
      update_attrs = %{message: "some updated message", from_user_id: "7488a646-e31f-11e4-aace-600308960668", detail: "some updated detail"}

      assert {:ok, %NotificationCommunity{} = notification_community} = Notifications.update_notification_community(notification_community, update_attrs)
      assert notification_community.message == "some updated message"
      assert notification_community.from_user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert notification_community.detail == "some updated detail"
    end

    test "update_notification_community/2 with invalid data returns error changeset" do
      notification_community = notification_community_fixture()
      assert {:error, %Ecto.Changeset{}} = Notifications.update_notification_community(notification_community, @invalid_attrs)
      assert notification_community == Notifications.get_notification_community!(notification_community.id)
    end

    test "delete_notification_community/1 deletes the notification_community" do
      notification_community = notification_community_fixture()
      assert {:ok, %NotificationCommunity{}} = Notifications.delete_notification_community(notification_community)
      assert_raise Ecto.NoResultsError, fn -> Notifications.get_notification_community!(notification_community.id) end
    end

    test "change_notification_community/1 returns a notification_community changeset" do
      notification_community = notification_community_fixture()
      assert %Ecto.Changeset{} = Notifications.change_notification_community(notification_community)
    end
  end
end
