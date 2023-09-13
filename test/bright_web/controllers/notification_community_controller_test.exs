defmodule BrightWeb.NotificationCommunityControllerTest do
  use BrightWeb.ConnCase

  import Bright.NotificationsFixtures

  alias Bright.Notifications.NotificationCommunity

  @create_attrs %{
    message: "some message",
    from_user_id: "7488a646-e31f-11e4-aace-600308960662",
    detail: "some detail"
  }
  @update_attrs %{
    message: "some updated message",
    from_user_id: "7488a646-e31f-11e4-aace-600308960668",
    detail: "some updated detail"
  }
  @invalid_attrs %{message: nil, from_user_id: nil, detail: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all notification_communities", %{conn: conn} do
      conn = get(conn, ~p"/api/notification_communities")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create notification_community" do
    test "renders notification_community when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/notification_communities", notification_community: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/notification_communities/#{id}")

      assert %{
               "id" => ^id,
               "detail" => "some detail",
               "from_user_id" => "7488a646-e31f-11e4-aace-600308960662",
               "message" => "some message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/notification_communities", notification_community: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update notification_community" do
    setup [:create_notification_community]

    test "renders notification_community when data is valid", %{conn: conn, notification_community: %NotificationCommunity{id: id} = notification_community} do
      conn = put(conn, ~p"/api/notification_communities/#{notification_community}", notification_community: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/notification_communities/#{id}")

      assert %{
               "id" => ^id,
               "detail" => "some updated detail",
               "from_user_id" => "7488a646-e31f-11e4-aace-600308960668",
               "message" => "some updated message"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, notification_community: notification_community} do
      conn = put(conn, ~p"/api/notification_communities/#{notification_community}", notification_community: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete notification_community" do
    setup [:create_notification_community]

    test "deletes chosen notification_community", %{conn: conn, notification_community: notification_community} do
      conn = delete(conn, ~p"/api/notification_communities/#{notification_community}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/notification_communities/#{notification_community}")
      end
    end
  end

  defp create_notification_community(_) do
    notification_community = notification_community_fixture()
    %{notification_community: notification_community}
  end
end
