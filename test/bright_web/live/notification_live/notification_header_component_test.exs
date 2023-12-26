defmodule BrightWeb.NotificationLive.NotificationHeaderComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.Repo
  alias Bright.Notifications.UserNotification

  describe "render" do
    setup [:register_and_log_in_user]

    test "opens header", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      refute lv |> has_element?(~s{a[href="/notifications/operations"]})
      refute lv |> has_element?(~s{a[href="/notifications/communities"]})
      refute lv |> has_element?(~s{a[href="/notifications/evidences"]})
      refute lv |> has_element?(~s{a[href="/notifications/skill_updates"]})

      assert lv |> element(~s{button[phx-click="toggle_notifications"]}) |> render_click()

      assert lv |> has_element?(~s{a[href="/notifications/operations"]})
      assert lv |> has_element?(~s{a[href="/notifications/communities"]})
      assert lv |> has_element?(~s{a[href="/notifications/evidences"]})
      assert lv |> has_element?(~s{a[href="/notifications/skill_updates"]})
    end

    test "renders notification unread batch when user does not have user_notification", %{
      conn: conn
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      assert lv |> has_element?("#notification_unread_batch")
    end

    test "renders notification unread batch when user has unread notificaiton", %{
      conn: conn,
      user: user
    } do
      last_viewed_at = NaiveDateTime.utc_now()
      from_user = insert(:user)
      insert(:user_notification, user: user, last_viewed_at: last_viewed_at)

      insert(:notification_operation,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(1)
      )

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      assert lv |> has_element?("#notification_unread_batch")
    end

    test "does not render notification unread batch when user does not have unread notificaiton",
         %{
           conn: conn,
           user: user
         } do
      last_viewed_at = NaiveDateTime.utc_now()
      from_user = insert(:user)
      insert(:user_notification, user: user, last_viewed_at: last_viewed_at)

      insert(:notification_operation,
        from_user: from_user,
        updated_at: last_viewed_at |> NaiveDateTime.add(-1)
      )

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      refute lv |> has_element?("#notification_unread_batch")
    end

    test "delete unread batch and creates user_notification when opens header", %{
      conn: conn,
      user: user
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      assert lv |> has_element?("#notification_unread_batch")

      assert lv |> element(~s{button[phx-click="toggle_notifications"]}) |> render_click()

      refute lv |> has_element?("#notification_unread_batch")

      assert Repo.get_by(UserNotification, user_id: user.id)
    end

    test "updated user_notifications.last_viewed_at when opens header", %{conn: conn, user: user} do
      before_last_viewed_at =
        NaiveDateTime.utc_now() |> NaiveDateTime.add(-1) |> NaiveDateTime.truncate(:second)

      insert(:user_notification, user: user, last_viewed_at: before_last_viewed_at)

      insert(:notification_operation,
        from_user: insert(:user),
        updated_at: before_last_viewed_at |> NaiveDateTime.add(1)
      )

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      assert lv |> has_element?("#notification_unread_batch")

      assert lv |> element(~s{button[phx-click="toggle_notifications"]}) |> render_click()

      refute lv |> has_element?("#notification_unread_batch")

      user_notification = Repo.get_by(UserNotification, user_id: user.id)

      assert before_last_viewed_at < user_notification.last_viewed_at
    end
  end
end
