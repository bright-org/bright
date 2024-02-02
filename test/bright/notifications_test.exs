defmodule Bright.NotificationsTest do
  use Bright.DataCase

  alias Bright.Repo
  alias Bright.Notifications

  alias Bright.Notifications.{
    NotificationOperation,
    NotificationCommunity,
    NotificationEvidence
  }

  import Bright.Factory
  import Swoosh.TestAssertions

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
    setup %{type: type} do
      from_user = insert(:user)
      to_user = insert(:user)

      {:ok,
       from_user: from_user,
       to_user: to_user,
       notifications: setup_notifications(type, from_user, to_user)}
    end

    defp setup_notifications("operation", from_user, _to_user) do
      insert_list(3, :notification_operation, from_user: from_user)
      |> Enum.sort_by(& &1.id, :desc)
    end

    defp setup_notifications("community", from_user, _to_user) do
      insert_list(3, :notification_community, from_user: from_user)
      |> Enum.sort_by(& &1.id, :desc)
    end

    defp setup_notifications("evidence", from_user, to_user) do
      insert_list(3, :notification_evidence, from_user: from_user, to_user: to_user)
      |> Enum.sort_by(& &1.id, :desc)
    end

    defp setup_notifications("skill_update", from_user, to_user) do
      insert_list(3, :notification_skill_update, from_user: from_user, to_user: to_user)
      |> Enum.sort_by(& &1.id, :desc)
    end

    defp setup_notifications("something", from_user, _to_user) do
      [
        insert(:notification_community, from_user: from_user),
        insert(:notification_operation, from_user: from_user)
      ]
    end

    @tag type: "operation"
    test "for type operation", %{notifications: notifications} do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } = Notifications.list_notification_by_type("", "operation", page: 1, page_size: 2)

      assert entries |> Enum.map(& &1.id) ==
               notifications |> Enum.take(2) |> Enum.map(& &1.id)
    end

    @tag type: "community"
    test "for type community", %{notifications: notifications} do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } = Notifications.list_notification_by_type("", "community", page: 1, page_size: 2)

      assert entries |> Enum.map(& &1.id) ==
               notifications |> Enum.take(2) |> Enum.map(& &1.id)
    end

    @tag type: "evidence"
    test "for type evidence", %{
      notifications: notifications,
      to_user: to_user
    } do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } =
               Notifications.list_notification_by_type(to_user.id, "evidence",
                 page: 1,
                 page_size: 2
               )

      assert entries |> Enum.map(& &1.id) ==
               notifications |> Enum.take(2) |> Enum.map(& &1.id)
    end

    @tag type: "evidence"
    test "for type evidence, returns the notifications of given to_user_id", %{
      to_user: to_user
    } do
      no_related_user = insert(:user)

      assert %{total_entries: 3} =
               Notifications.list_notification_by_type(to_user.id, "evidence", page: 1)

      assert %{total_entries: 0} =
               Notifications.list_notification_by_type(no_related_user.id, "evidence", page: 1)
    end

    @tag type: "skill_update"
    test "for type skill_update", %{
      notifications: notifications,
      to_user: to_user
    } do
      assert %{
               entries: entries,
               page_number: 1,
               page_size: 2,
               total_entries: 3,
               total_pages: 2
             } =
               Notifications.list_notification_by_type(to_user.id, "skill_update",
                 page: 1,
                 page_size: 2
               )

      assert entries |> Enum.map(& &1.id) ==
               notifications |> Enum.take(2) |> Enum.map(& &1.id)
    end

    @tag type: "skill_update"
    test "for type skill_update, returns the notifications of given to_user_id", %{
      to_user: to_user
    } do
      no_related_user = insert(:user)

      assert %{total_entries: 3} =
               Notifications.list_notification_by_type(to_user.id, "skill_update", page: 1)

      assert %{total_entries: 0} =
               Notifications.list_notification_by_type(no_related_user.id, "skill_update", page: 1)
    end

    @tag type: "something"
    test "returns the notifications of given type" do
      %{entries: [entry]} =
        Notifications.list_notification_by_type("", "operation", page: 1, page_size: 1)

      assert %NotificationOperation{} = entry

      %{entries: [entry]} =
        Notifications.list_notification_by_type("", "community", page: 1, page_size: 1)

      assert %NotificationCommunity{} = entry
    end
  end

  describe "create_notification/2" do
    test "with valid data for type operation" do
      from_user = insert(:user)

      valid_attrs = %{
        message: "some message",
        from_user_id: from_user.id,
        detail: "some detail"
      }

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.create_notification("operation", valid_attrs)

      assert notification_operation.message == "some message"
      assert notification_operation.from_user_id == from_user.id
      assert notification_operation.detail == "some detail"
    end

    test "sends operations notification mails when create operation" do
      from_user = insert(:user)
      user = insert(:user)
      insert(:user_not_confirmed)
      insert(:user_not_confirmed)
      from_user_sub_email = insert(:user_sub_email, user: from_user)
      user_sub_email = insert(:user_sub_email, user: user)

      Application.put_env(:bright, :max_deliver_size, 2)

      assert {:ok, %NotificationOperation{} = notification_operation} =
               Notifications.create_notification("operation", %{
                 message: "some message",
                 from_user_id: from_user.id,
                 detail: "some detail"
               })

      assert_operations_notification_mail_sent(notification_operation, [
        from_user.email,
        user.email
      ])

      assert_operations_notification_mail_sent(notification_operation, [
        from_user_sub_email.email,
        user_sub_email.email
      ])
    end

    test "with invalid data for type operation" do
      invalid_attrs = %{message: nil, from_user_id: nil, detail: nil}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification("operation", invalid_attrs)

      assert_no_email_sent()
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

    test "with valid data for type evidence" do
      from_user = insert(:user)
      to_user = insert(:user)

      valid_attrs = %{
        message: "some message",
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        url: "/"
      }

      assert {:ok, %NotificationEvidence{} = notification_evidence} =
               Notifications.create_notification("evidence", valid_attrs)

      assert notification_evidence.message == "some message"
      assert notification_evidence.from_user_id == from_user.id
      assert notification_evidence.to_user_id == to_user.id
      assert notification_evidence.url == "/"
    end

    test "with invalid data for type evidence" do
      invalid_attrs = %{message: nil}

      assert {:error, %Ecto.Changeset{}} =
               Notifications.create_notification("evidence", invalid_attrs)
    end
  end

  describe "create_notifications/2" do
    test "with valid data for type evidence" do
      from_user = insert(:user)
      to_user = insert(:user)
      timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      valid_attrs = %{
        id: Ecto.ULID.generate(),
        message: "some message",
        from_user_id: from_user.id,
        to_user_id: to_user.id,
        url: "/",
        inserted_at: timestamp,
        updated_at: timestamp
      }

      assert {1, _} = Notifications.create_notifications("evidence", [valid_attrs])
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

  describe "has_unread_notification?/1" do
    test "returns true if the user does not have user_notifications record" do
      user = insert(:user)

      assert Notifications.has_unread_notification?(user)
    end

    test "returns true if the user has unread notification_operation" do
      last_viewed_at = NaiveDateTime.utc_now()
      [from_user, to_user] = insert_pair(:user)
      insert(:user_notification, user: to_user, last_viewed_at: last_viewed_at)

      insert(:notification_operation,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(1)
      )

      assert Notifications.has_unread_notification?(to_user)
    end

    test "returns true if the user has unread notification_community" do
      last_viewed_at = NaiveDateTime.utc_now()
      [from_user, to_user] = insert_pair(:user)
      insert(:user_notification, user: to_user, last_viewed_at: last_viewed_at)

      insert(:notification_community,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(1)
      )

      assert Notifications.has_unread_notification?(to_user)
    end

    test "returns true if the user has unread notification_evidence" do
      last_viewed_at = NaiveDateTime.utc_now()
      [from_user, to_user] = insert_pair(:user)
      insert(:user_notification, user: to_user, last_viewed_at: last_viewed_at)

      insert(:notification_evidence,
        from_user: from_user,
        to_user: to_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(1)
      )

      assert Notifications.has_unread_notification?(to_user)
    end

    test "returns true if the user has unread notification_skill_update" do
      last_viewed_at = NaiveDateTime.utc_now()
      [from_user, to_user] = insert_pair(:user)
      insert(:user_notification, user: to_user, last_viewed_at: last_viewed_at)

      insert(:notification_skill_update,
        from_user: from_user,
        to_user: to_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(1)
      )

      assert Notifications.has_unread_notification?(to_user)
    end

    test "returns false if the user does not have unread notification" do
      last_viewed_at = NaiveDateTime.utc_now()
      [from_user, to_user] = insert_pair(:user)
      insert(:user_notification, user: to_user, last_viewed_at: last_viewed_at)

      insert(:notification_operation,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(-1)
      )

      insert(:notification_community,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(-1)
      )

      insert(:notification_evidence,
        from_user: from_user,
        to_user: to_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(-1)
      )

      refute Notifications.has_unread_notification?(to_user)
    end
  end

  describe "view_notification/1" do
    test "creates user_notifications record when user does not have" do
      user = insert(:user)

      Notifications.view_notification(user)

      assert user |> Repo.preload(:user_notification) |> Map.get(:user_notification)
    end

    test "updated user_notification.last_viewed_at when user has" do
      before_last_viewed_at = NaiveDateTime.utc_now() |> NaiveDateTime.add(-1)

      user = insert(:user)

      user_notification =
        insert(:user_notification, user: user, last_viewed_at: before_last_viewed_at)

      Notifications.view_notification(user)

      assert user_notification.last_viewed_at <
               user
               |> Repo.preload(:user_notification)
               |> Map.get(:user_notification)
               |> Map.get(:last_viewed_at)
    end
  end

  describe "list_related_user_ids" do
    setup do
      # 自身と所属チーム
      user = insert(:user)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)

      %{user: user, team: team}
    end

    setup %{team: team} do
      # チームメンバー
      team_users = insert_pair(:user)
      Enum.each(team_users, &insert(:team_member_users, team: team, user: &1))

      %{team_users: team_users}
    end

    setup %{user: user} do
      # 支援元チームメンバー
      supporter_users = insert_pair(:user)
      Enum.each(supporter_users, &relate_user_and_supporter(user, &1))

      %{supporter_users: supporter_users}
    end

    setup %{user: user} do
      # 支援先チームメンバー
      supportee_users = insert_pair(:user)
      Enum.each(supportee_users, &relate_user_and_supporter(&1, user))

      %{supportee_users: supportee_users}
    end

    test "returns user_ids of teams, support_teams and supportee teams", %{
      user: user,
      team_users: team_users,
      supporter_users: supporter_users,
      supportee_users: supportee_users
    } do
      related_user_ids = Notifications.list_related_user_ids(user)

      assert Enum.all?(team_users, &(&1.id in related_user_ids))
      assert Enum.all?(supporter_users, &(&1.id in related_user_ids))
      assert Enum.all?(supportee_users, &(&1.id in related_user_ids))
    end

    test "no unrelated users are included", %{
      user: user
    } do
      user_2 = insert(:user)
      related_user_ids = Notifications.list_related_user_ids(user)

      refute user_2.id in related_user_ids
      assert [] = Notifications.list_related_user_ids(user_2)
    end
  end
end
