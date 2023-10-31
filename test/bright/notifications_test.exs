defmodule Bright.NotificationsTest do
  use Bright.DataCase

  alias Bright.Repo
  alias Bright.Notifications
  alias Bright.Notifications.NotificationOperation
  alias Bright.Notifications.NotificationCommunity

  import Bright.Factory

  describe "list_all_notifications/1" do
    test "for type operation" do
      notification_operation = insert(:notification_operation)

      assert Notifications.list_all_notifications("operation")
             |> Repo.preload(:from_user) ==
               [notification_operation]
    end

    test "for type community" do
      notification_community = insert(:notification_community)

      assert Notifications.list_all_notifications("community")
             |> Repo.preload(:from_user) ==
               [notification_community]
    end
  end

  describe "get_notification!/2" do
    test "for type operation" do
      notification = insert(:notification_operation)

      assert Notifications.get_notification!("operation", notification.id)

      other_notification = insert(:notification_community)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification!("operation", other_notification.id)
      end
    end
  end

  describe "list_notification_by_type/3" do
    setup do
      from_user = insert(:user)

      {:ok,
       from_user: from_user,
       notification_operations:
         insert_list(3, :notification_operation, from_user: from_user)
         |> Enum.sort_by(& &1.id)
         |> Enum.reverse(),
       notification_communities:
         insert_list(3, :notification_community, from_user: from_user)
         |> Enum.sort_by(& &1.id)
         |> Enum.reverse()}
    end

    test "for type operation", %{notification_operations: notification_operations} do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } = Notifications.list_notification_by_type("", "operation", page: 1, page_size: 2)

      assert entries |> Enum.map(& &1.id) ==
               notification_operations |> Enum.take(2) |> Enum.map(& &1.id)
    end

    test "for type community", %{notification_communities: notification_communities} do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } = Notifications.list_notification_by_type("", "community", page: 1, page_size: 2)

      assert entries |> Enum.map(& &1.id) ==
               notification_communities |> Enum.take(2) |> Enum.map(& &1.id)
    end
  end

  describe "confirm_notification!/1" do
    test "for type operation" do
      notification = insert(:notification_operation, confirmed_at: nil)

      Notifications.confirm_notification!(notification)

      assert Repo.get!(Notifications.NotificationOperation, notification.id).confirmed_at
    end

    test "for type community" do
      notification = insert(:notification_community, confirmed_at: nil)

      Notifications.confirm_notification!(notification)

      assert Repo.get!(Notifications.NotificationCommunity, notification.id).confirmed_at
    end

    test "does not update confirmed_at when already confirmed" do
      previous_confirmed_at =
        NaiveDateTime.utc_now() |> NaiveDateTime.add(-1 * 3600) |> NaiveDateTime.truncate(:second)

      notification = insert(:notification_operation, confirmed_at: previous_confirmed_at)

      Notifications.confirm_notification!(notification)

      assert previous_confirmed_at ==
               Repo.get!(Notifications.NotificationOperation, notification.id).confirmed_at
    end
  end

  describe "list_unconfirmed_notification_count/1" do
    test "returns unconfirmed_notification_count by user" do
      from_user = insert(:user)
      to_user = insert(:user)

      insert_pair(:notification_operation, from_user: from_user, confirmed_at: nil)
      insert(:notification_operation, from_user: from_user, confirmed_at: NaiveDateTime.utc_now())
      insert_pair(:notification_community, from_user: from_user, confirmed_at: nil)
      insert(:notification_community, from_user: from_user, confirmed_at: NaiveDateTime.utc_now())

      assert %{"operation" => 2, "community" => 2} ==
               Notifications.list_unconfirmed_notification_count(to_user)
    end
  end

  describe "create_notification/2" do
    test "with valid data for type operation" do
      user = insert(:user)

      valid_attrs = %{
        message: "some message",
        from_user_id: user.id,
        detail: "some detail"
      }

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.create_notification("operation", valid_attrs)

      assert notification_operation.message == "some message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some detail"
    end

    test "with invalid data for type operation" do
      invalid_attrs = %{message: nil, from_user_id: nil, detail: nil}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification("operation", invalid_attrs)
    end

    test "with valid data for type community" do
      from_user = insert(:user)

      valid_attrs = %{message: "some message", from_user_id: from_user.id, detail: "some detail"}

      assert {:ok, %NotificationCommunity{} = notification_community} =
               Notifications.create_notification("community", valid_attrs)

      assert notification_community.message == "some message"
      assert notification_community.from_user_id == from_user.id
      assert notification_community.detail == "some detail"
    end

    test "with invalid data for type community" do
      invalid_attrs = %{message: nil, from_user_id: nil, detail: nil}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification("community", invalid_attrs)
    end
  end

  describe "update_notification/2" do
    test "with valid data for type operation" do
      notification_operation = insert(:notification_operation)

      user = insert(:user)

      update_attrs = %{
        message: "some updated message",
        from_user_id: user.id,
        detail: "some updated detail"
      }

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.update_notification(
                 notification_operation,
                 update_attrs
               )

      assert notification_operation.message == "some updated message"
      assert notification_operation.from_user_id == user.id
      assert notification_operation.detail == "some updated detail"
    end

    test "with invalid data for type operation" do
      invalid_attrs = %{message: nil, from_user_id: nil, detail: nil}
      notification_operation = insert(:notification_operation)

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification(
                 notification_operation,
                 invalid_attrs
               )

      assert notification_operation ==
               Notifications.get_notification!("operation", notification_operation.id)
               |> Repo.preload(:from_user)
    end

    test "with valid data for type community" do
      notification_community = insert(:notification_community)
      from_user = insert(:user)

      update_attrs = %{
        message: "some updated message",
        from_user_id: from_user.id,
        detail: "some updated detail"
      }

      assert {:ok, %NotificationCommunity{} = notification_community} =
               Notifications.update_notification(
                 notification_community,
                 update_attrs
               )

      assert notification_community.message == "some updated message"
      assert notification_community.from_user_id == from_user.id
      assert notification_community.detail == "some updated detail"
    end

    test "with invalid data for type community" do
      invalid_attrs = %{message: nil, from_user_id: nil, detail: nil}
      notification_community = insert(:notification_community)

      assert {:error, %Ecto.Changeset{}} =
               Notifications.update_notification(
                 notification_community,
                 invalid_attrs
               )

      assert notification_community ==
               Notifications.get_notification!("community", notification_community.id)
               |> Repo.preload(:from_user)
    end
  end

  describe "delete_notification/1" do
    test "for type operation" do
      notification_operation = insert(:notification_operation)

      assert {:ok, %NotificationOperation{}} =
               Notifications.delete_notification(notification_operation)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification!("operation", notification_operation.id)
      end
    end

    test "for type community" do
      notification_community = insert(:notification_community)

      assert {:ok, %NotificationCommunity{}} =
               Notifications.delete_notification(notification_community)

      assert_raise Ecto.NoResultsError, fn ->
        Notifications.get_notification!("community", notification_community.id)
      end
    end
  end

  describe "change_notification/1" do
    test "for type operation" do
      notification_operation = insert(:notification_operation)

      assert %Ecto.Changeset{} = Notifications.change_notification(notification_operation)
    end

    test "for type community" do
      notification_community = insert(:notification_community)

      assert %Ecto.Changeset{} = Notifications.change_notification(notification_community)
    end
  end
end
