defmodule BrightWeb.NotificationOfficialTeamControllerTest do
  use BrightWeb.ConnCase

  import Bright.Factory

  alias Bright.Notifications.NotificationOfficialTeam

  @create_attrs %{
    message: "some message",
    detail: "some detail",
    from_user_id: "7488a646-e31f-11e4-aace-600308960662",
    to_user_id: "7488a646-e31f-11e4-aace-600308960662",
    participation: true
  }

  defp create_attrs do
    from_user = insert(:user)
    to_user = insert(:user)

    %{
      message: "some message",
      detail: "some detail",
      from_user_id: from_user.id,
      to_user_id: from_user.id,
      participation: true
    }
  end

  @update_attrs %{
    message: "some updated message",
    detail: "some updated detail",
    from_user_id: "7488a646-e31f-11e4-aace-600308960668",
    to_user_id: "7488a646-e31f-11e4-aace-600308960668",
    participation: false
  }
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
      # create_attrs = create_attrs()
      # conn = post(conn, ~p"/api/notification_official_teams", notification_official_team: create_attrs)
      # |> IO.inspect()
      # json_response(conn, 201)["data"] |> IO.inspect()
      # assert %{"id" => id} = json_response(conn, 201)["data"]

      # conn = get(conn, ~p"/api/notification_official_teams/#{id}")

      # assert %{
      #          "id" => ^id,
      #          "detail" => "some detail",
      #          "from_user_id" => "7488a646-e31f-11e4-aace-600308960662",
      #          "message" => "some message",
      #          "participation" => true,
      #          "to_user_id" => "7488a646-e31f-11e4-aace-600308960662"
      #        } = json_response(conn, 200)["data"]
    end

    # test "renders errors when data is invalid", %{conn: conn} do
    #   conn = post(conn, ~p"/api/notification_official_teams", notification_official_team: @invalid_attrs)
    #   assert json_response(conn, 422)["errors"] != %{}
    # end
  end

  # describe "update notification_official_team" do
  #   setup [:create_notification_official_team]

  #   test "renders notification_official_team when data is valid", %{conn: conn, notification_official_team: %NotificationOfficialTeam{id: id} = notification_official_team} do
  #     conn = put(conn, ~p"/api/notification_official_teams/#{notification_official_team}", notification_official_team: @update_attrs)
  #     assert %{"id" => ^id} = json_response(conn, 200)["data"]

  #     conn = get(conn, ~p"/api/notification_official_teams/#{id}")

  #     assert %{
  #              "id" => ^id,
  #              "detail" => "some updated detail",
  #              "from_user_id" => "7488a646-e31f-11e4-aace-600308960668",
  #              "message" => "some updated message",
  #              "participation" => false,
  #              "to_user_id" => "7488a646-e31f-11e4-aace-600308960668"
  #            } = json_response(conn, 200)["data"]
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, notification_official_team: notification_official_team} do
  #     conn = put(conn, ~p"/api/notification_official_teams/#{notification_official_team}", notification_official_team: @invalid_attrs)
  #     assert json_response(conn, 422)["errors"] != %{}
  #   end
  # end

  # describe "delete notification_official_team" do
  #   setup [:create_notification_official_team]

  #   test "deletes chosen notification_official_team", %{conn: conn, notification_official_team: notification_official_team} do
  #     conn = delete(conn, ~p"/api/notification_official_teams/#{notification_official_team}")
  #     assert response(conn, 204)

  #     assert_error_sent 404, fn ->
  #       get(conn, ~p"/api/notification_official_teams/#{notification_official_team}")
  #     end
  #   end
  # end

  defp create_notification_official_team(_) do
    notification_official_team = insert(:notification_official_team)
    %{notification_official_team: notification_official_team}
  end
end
