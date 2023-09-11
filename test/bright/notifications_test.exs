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

  describe "notification_operations" do
    alias Bright.Notifications.NotificationOperation

    @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

    test "list_notification_operations/0 returns all notification_operations" do
      notification_operation = insert(:notification_operation)

      assert Notifications.list_notification_operations() |> Repo.preload(:from_user) == [
               notification_operation
             ]
    end

    test "get_notification_operation!/1 returns the notification_operation with given id" do
      notification_operation = insert(:notification_operation)

      assert Notifications.get_notification_operation!(notification_operation.id)
             |> Repo.preload(:from_user) ==
               notification_operation
    end

    test "create_notification_operation/1 with valid data creates a notification_operation" do
      user = insert(:user)

      valid_attrs = %{
        message: "some message",
        from_user_id: user.id,
        detail: "some detail"
      }

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.create_notification_operation(valid_attrs)

      assert notification_operation.message == "some message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some detail"
    end

    test "create_notification_operation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification_operation(@invalid_attrs)
    end

    test "update_notification_operation/2 with valid data updates the notification_operation" do
      notification_operation = insert(:notification_operation)

      user = insert(:user)

      update_attrs = %{
        message: "some updated message",
        from_user_id: user.id,
        detail: "some updated detail"
      }

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.update_notification_operation(notification_operation, update_attrs)

      assert notification_operation.message == "some updated message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some updated detail"
    end

    test "update_notification_operation/2 with invalid data returns error changeset" do
      notification_operation = insert(:notification_operation)

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification_operation(notification_operation, @invalid_attrs)

      assert notification_operation ==
               Notifications.get_notification_operation!(notification_operation.id)
               |> Repo.preload(:from_user)
    end

    test "delete_notification_operation/1 deletes the notification_operation" do
      notification_operation = insert(:notification_operation)

      assert {:ok, %NotificationOperation{}} =
               Notifications.delete_notification_operation(notification_operation)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification_operation!(notification_operation.id)
      end
    end

    test "change_notification_operation/1 returns a notification_operation changeset" do
      notification_operation = insert(:notification_operation)

      assert %Ecto.Changeset{} =
               Notifications.change_notification_operation(notification_operation)
    end
  end
end
