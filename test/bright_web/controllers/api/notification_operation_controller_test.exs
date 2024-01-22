defmodule BrightWeb.Api.NotificationOperationControllerTest do
  use BrightWeb.ConnCase
  import Bright.Factory
  import Swoosh.TestAssertions

  alias Bright.Notifications.NotificationOperation

  defp create_attrs(from_user) do
    %{
      message: "some message",
      from_user_id: from_user.id,
      detail: "some detail"
    }
  end

  defp update_attrs(from_user) do
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

  describe "without basic auth" do
    test "index", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/notification_operations")
      assert response(conn, 401)
    end

    test "create", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/notification_operations", notification_operation: %{})
      assert response(conn, 401)
    end

    test "update", %{conn: conn} do
      conn = put(conn, ~p"/api/v1/notification_operations/1", notification_operation: %{})
      assert response(conn, 401)
    end

    test "delete", %{conn: conn} do
      conn = delete(conn, ~p"/api/v1/notification_operations/1")
      assert response(conn, 401)
    end
  end

  describe "index" do
    setup [:setup_api_basic_auth]

    test "lists all notification_operations", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/notification_operations")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create notification_operation" do
    setup [:setup_api_basic_auth]

    test "renders notification_operation when data is valid", %{conn: conn} do
      from_user = insert(:user)
      from_user_id = from_user.id
      attrs = create_attrs(from_user)

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

    test "sends mails to confirmed_users", %{conn: conn} do
      from_user = insert(:user)
      attrs = create_attrs(from_user)

      user = insert(:user)
      user_sub_email = insert(:user_sub_email, user: user)
      insert(:user_not_confirmed)
      insert(:user_not_confirmed)

      post(conn, ~p"/api/v1/notification_operations", notification_operation: attrs)

      assert_operations_notification_mail_sent([from_user.email, user.email, user_sub_email.email])
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/notification_operations", notification_operation: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
      assert_no_email_sent()
    end
  end

  describe "update notification_operation" do
    setup [:create_notification_operation, :setup_api_basic_auth]

    test "renders notification_operation when data is valid", %{
      conn: conn,
      notification_operation: %NotificationOperation{id: id} = notification_operation
    } do
      from_user = insert(:user)
      attrs = update_attrs(from_user)

      conn =
        put(conn, ~p"/api/v1/notification_operations/#{notification_operation}",
          notification_operation: attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/v1/notification_operations/#{id}")

      from_user_id = from_user.id

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
    setup [:create_notification_operation, :setup_api_basic_auth]

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
