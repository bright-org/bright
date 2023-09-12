defmodule Bright.NotificationOperationsTest do
  use Bright.DataCase

  alias Bright.NotificationOperations

  import Bright.Factory

  describe "notification_operations" do
    alias Bright.Notifications.NotificationOperation

    @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

    test "list_notification_operations/0 returns all notification_operations" do
      notification_operation = insert(:notification_operation)

      assert NotificationOperations.list_notification_operations() |> Repo.preload(:from_user) ==
               [
                 notification_operation
               ]
    end

    test "get_notification_operation!/1 returns the notification_operation with given id" do
      notification_operation = insert(:notification_operation)

      assert NotificationOperations.get_notification_operation!(notification_operation.id)
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
               NotificationOperations.create_notification_operation(valid_attrs)

      assert notification_operation.message == "some message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some detail"
    end

    test "create_notification_operation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               NotificationOperations.create_notification_operation(@invalid_attrs)
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
               NotificationOperations.update_notification_operation(
                 notification_operation,
                 update_attrs
               )

      assert notification_operation.message == "some updated message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some updated detail"
    end

    test "update_notification_operation/2 with invalid data returns error changeset" do
      notification_operation = insert(:notification_operation)

      assert {:error, %Ecto.Changeset{}} =
               NotificationOperations.update_notification_operation(
                 notification_operation,
                 @invalid_attrs
               )

      assert notification_operation ==
               NotificationOperations.get_notification_operation!(notification_operation.id)
               |> Repo.preload(:from_user)
    end

    test "delete_notification_operation/1 deletes the notification_operation" do
      notification_operation = insert(:notification_operation)

      assert {:ok, %NotificationOperation{}} =
               NotificationOperations.delete_notification_operation(notification_operation)

      assert_raise Ecto.NoResultsError, fn ->
        NotificationOperations.get_notification_operation!(notification_operation.id)
      end
    end

    test "change_notification_operation/1 returns a notification_operation changeset" do
      notification_operation = insert(:notification_operation)

      assert %Ecto.Changeset{} =
               NotificationOperations.change_notification_operation(notification_operation)
    end
  end
end
