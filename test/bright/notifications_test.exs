defmodule Bright.NotificationsTest do
  use Bright.DataCase

  alias Bright.Notifications

  import Bright.Factory

  describe "notifications" do
    alias Bright.Notifications.Notification

    @invalid_attrs %{
      message: nil,
      type: nil,
      url: nil,
      from_user_id: nil,
      to_user_id: nil,
      icon_type: nil,
      read_at: nil
    }

    test "list_notifications/0 returns all notifications" do
      notification = insert(:notification)
      assert Notifications.list_notifications() == [notification]
    end

    test "get_notification!/2 returns the notification with given id" do
      notification = insert(:notification)
      assert Notifications.get_notification!("test", notification.id) == notification
    end

    # TODO Scrivenerのテスト未実施
    test "list_notification_by_type/0 returns all notifications" do
      notification =
        insert(:notification)
        |> delete_user()

      ret =
        Notifications.list_notification_by_type(notification.to_user_id, notification.type, %{})
        |> Enum.at(0)
        |> delete_user()

      assert ret == notification
    end

    defp delete_user(notification) do
      notification
      |> Map.delete(:from_user)
      |> Map.delete(:to_user)
    end

    test "create_notification/1 with valid data creates a notification" do
      from_user = insert(:user)
      to_user = insert(:user)

      valid_attrs = %{
        message: "some message",
        type: "some type",
        url: "some url",
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        icon_type: "some icon_type",
        read_at: ~N[2023-07-07 10:08:00]
      }

      assert {:ok, %Notification{} = notification} =
               Notifications.create_notification(valid_attrs)

      assert notification.message == "some message"
      assert notification.type == "some type"
      assert notification.url == "some url"
      assert notification.from_user_id == from_user.id
      assert notification.to_user_id == to_user.id
      assert notification.icon_type == "some icon_type"
      assert notification.read_at == ~N[2023-07-07 10:08:00]
    end

    test "create_notification/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Notifications.create_notification(@invalid_attrs)
    end

    test "update_notification/2 with valid data updates the notification" do
      notification = insert(:notification)

      from_user = insert(:user)
      to_user = insert(:user)

      update_attrs = %{
        message: "some updated message",
        type: "some updated type",
        url: "some updated url",
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        icon_type: "some updated icon_type",
        read_at: ~N[2023-07-08 10:08:00]
      }

      assert {:ok, %Notification{} = notification} =
               Notifications.update_notification(notification, update_attrs)

      assert notification.message == "some updated message"
      assert notification.type == "some updated type"
      assert notification.url == "some updated url"
      assert notification.from_user_id == from_user.id
      assert notification.to_user_id == to_user.id
      assert notification.icon_type == "some updated icon_type"
      assert notification.read_at == ~N[2023-07-08 10:08:00]
    end

    test "update_notification/2 with invalid data returns error changeset" do
      notification = insert(:notification)

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification(notification, @invalid_attrs)

      assert notification == Notifications.get_notification!("test", notification.id)
    end

    test "delete_notification/1 deletes the notification" do
      notification = insert(:notification)
      assert {:ok, %Notification{}} = Notifications.delete_notification(notification)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification!("test", notification.id)
      end
    end

    test "change_notification/1 returns a notification changeset" do
      notification = insert(:notification)
      assert %Ecto.Changeset{} = Notifications.change_notification(notification)
    end
  end

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
