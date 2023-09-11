defmodule BrightWeb.NotificationOperationControllerTest do
  use BrightWeb.ConnCase
  import Bright.Factory
  alias Bright.Notifications.NotificationOperation

  defp create_attrs() do
    from_user = insert(:user)

    %{
      message: "some message",
      from_user_id: from_user.id,
      detail: "some detail"
    }
  end

  defp update_attrs() do
    from_user = insert(:user)

    %{
      message: "some updated message",
      from_user_id: from_user.id,
      detail: "some updated detail"
    }
  end

  @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all notification_operations", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/notification_operations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create notification_operation" do
    test "renders notification_operation when data is valid", %{conn: conn} do
      attrs = create_attrs()
      from_user_id = attrs.from_user_id
      conn = post(conn, ~p"/api/v1/notification_operations", notification_operation: attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/notification_operations/#{id}")

      assert %{
               "id" => ^id,
               "detail" => "some detail",
               "from_user_id" => ^from_user_id,
               "message" => "some message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/notification_operations", notification_operation: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update notification_operation" do
    setup [:create_notification_operation]

    test "renders notification_operation when data is valid", %{
      conn: conn,
      notification_operation: %NotificationOperation{id: id} = notification_operation
    } do
      attrs = update_attrs()

      conn =
        put(conn, ~p"/api/v1/notification_operations/#{notification_operation}",
          notification_operation: attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/v1/notification_operations/#{id}")

      from_user_id = attrs.from_user_id

      assert %{
               "id" => ^id,
               "detail" => "some updated detail",
               "from_user_id" => ^from_user_id,
               "message" => "some updated message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      notification_operation: notification_operation
    } do
      conn =
        put(conn, ~p"/api/v1/notification_operations/#{notification_operation}",
          notification_operation: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete notification_operation" do
    setup [:create_notification_operation]

    test "deletes chosen notification_operation", %{
      conn: conn,
      notification_operation: notification_operation
    } do
      conn = delete(conn, ~p"/api/v1/notification_operations/#{notification_operation}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/notification_operations/#{notification_operation}")
      end
    end
  end

  defp create_notification_operation(_) do
    notification_operation = insert(:notification_operation)
    %{notification_operation: notification_operation}
  end
end
