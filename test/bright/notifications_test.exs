defmodule Bright.NotificationsTest do
  use Bright.DataCase

  alias Bright.Repo
  alias Bright.Notifications

  import Bright.Factory

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

      assert %{"operation" => 2} == Notifications.list_unconfirmed_notification_count(to_user)
    end
  end
end
