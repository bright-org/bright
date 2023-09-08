defmodule BrightWeb.NotificationOfficialTeamControllerTest do
  use BrightWeb.ConnCase

  import Bright.Factory

  alias Bright.Notifications.NotificationOfficialTeam

  defp create_attrs do
    from_user = insert(:user)
    to_user = insert(:user)

    %{
      message: "some message",
      detail: "some detail",
      from_user_id: from_user.id,
      to_user_id: to_user.id,
      participation: true
    }
  end

  defp update_attrs do
    from_user = insert(:user)
    to_user = insert(:user)

    %{
      message: "some updated message",
      detail: "some updated detail",
      from_user_id: from_user.id,
      to_user_id: to_user.id,
      participation: false
    }
  end

  @invalid_attrs %{
    message: nil,
    detail: nil,
    from_user_id: nil,
    to_user_id: nil,
    participation: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all notification_official_teams", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/notification_official_teams")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create notification_official_team" do
    test "renders notification_official_team when data is valid", %{conn: conn} do
      attrs = create_attrs()
      from_user_id = attrs.from_user_id
      to_user_id = attrs.to_user_id

      conn =
        post(conn, ~p"/api/v1/notification_official_teams", notification_official_team: attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/v1/notification_official_teams/#{id}")

      assert %{
               "id" => ^id,
               "detail" => "some detail",
               "from_user_id" => ^from_user_id,
               "message" => "some message",
               "participation" => true,
               "to_user_id" => ^to_user_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, ~p"/api/v1/notification_official_teams",
          notification_official_team: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update notification_official_team" do
    setup [:create_notification_official_team]

    test "renders notification_official_team when data is valid", %{
      conn: conn,
      notification_official_team: %NotificationOfficialTeam{id: id} = notification_official_team
    } do
      attrs = update_attrs()
      from_user_id = attrs.from_user_id
      to_user_id = attrs.to_user_id

      conn =
        put(conn, ~p"/api/v1/notification_official_teams/#{notification_official_team}",
          notification_official_team: attrs
        )

      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/v1/notification_official_teams/#{id}")

      assert %{
               "id" => ^id,
               "detail" => "some updated detail",
               "from_user_id" => ^from_user_id,
               "message" => "some updated message",
               "participation" => false,
               "to_user_id" => ^to_user_id
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      notification_official_team: notification_official_team
    } do
      conn =
        put(conn, ~p"/api/v1/notification_official_teams/#{notification_official_team}",
          notification_official_team: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete notification_official_team" do
    setup [:create_notification_official_team]

    test "deletes chosen notification_official_team", %{
      conn: conn,
      notification_official_team: notification_official_team
    } do
      conn = delete(conn, ~p"/api/v1/notification_official_teams/#{notification_official_team}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/v1/notification_official_teams/#{notification_official_team}")
      end
    end
  end

  defp create_notification_official_team(_) do
    notification_official_team = insert(:notification_official_team)
    %{notification_official_team: notification_official_team}
  end
end
