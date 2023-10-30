defmodule BrightWeb.NotificationLive.OperationTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.Repo
  alias Bright.Notifications.NotificationOperation

  setup [:register_and_log_in_user]

  describe "render page" do
    test "renders page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/notifications/operations")

      assert html =~ "運営からの通知"
      assert html =~ "運営からの通知はありません"

      insert(:notification_operation)

      {:ok, _lv, html} = live(conn, ~p"/notifications/operations")

      refute html =~ "運営からの通知はありません"
    end
  end

  describe "render paginated notifications" do
    test "renders paginated notifications", %{conn: conn} do
      notification_operations =
        insert_list(11, :notification_operation) |> Enum.sort_by(& &1.id) |> Enum.reverse()

      {:ok, lv, _html} = live(conn, ~p"/notifications/operations")

      notification_message_10 = notification_operations |> Enum.at(9) |> Map.get(:message)
      notification_message_11 = notification_operations |> Enum.at(10) |> Map.get(:message)

      assert lv |> has_element?("#notification_operation_container span", notification_message_10)
      refute lv |> has_element?("#notification_operation_container span", notification_message_11)

      lv |> element(~s{button[phx-click="next_button_click"]}) |> render_click()

      refute lv |> has_element?("#notification_operation_container span", notification_message_10)
      assert lv |> has_element?("#notification_operation_container span", notification_message_11)

      lv |> element(~s{button[phx-click="previous_button_click"]}) |> render_click()

      assert lv |> has_element?("#notification_operation_container span", notification_message_10)
      refute lv |> has_element?("#notification_operation_container span", notification_message_11)
    end
  end

  describe "notification modal and updating confirmed_at" do
    test "shows modal and updates confirmed_at", %{conn: conn} do
      notification_operation = insert(:notification_operation)

      {:ok, lv, _html} = live(conn, ~p"/notifications/operations")

      refute Repo.get(NotificationOperation, notification_operation.id).confirmed_at
      refute lv |> has_element?("#notification_operation_modal")
      refute lv |> has_element?("#notification_operation_modal", notification_operation.detail)

      lv
      |> element(~s{div[phx-click="confirm_notification"]}, notification_operation.message)
      |> render_click()

      assert Repo.get(NotificationOperation, notification_operation.id).confirmed_at
      assert lv |> has_element?("#notification_operation_modal")
      assert lv |> has_element?("#notification_operation_modal", notification_operation.detail)
    end

    test "makes style font-bold to unconfirmed message", %{conn: conn} do
      notification_operation = insert(:notification_operation)

      {:ok, lv, _html} = live(conn, ~p"/notifications/operations")

      assert lv
             |> has_element?(
               "#notification_operation_container span.font-bold",
               notification_operation.message
             )
    end

    test "does not make style font-bold to confirmed message", %{conn: conn} do
      notification_operation =
        insert(:notification_operation, confirmed_at: NaiveDateTime.utc_now())

      {:ok, lv, _html} = live(conn, ~p"/notifications/operations")

      refute lv
             |> has_element?(
               "#notification_operation_container span.font-bold",
               notification_operation.message
             )
    end
  end
end
