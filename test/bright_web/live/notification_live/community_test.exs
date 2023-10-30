defmodule BrightWeb.NotificationLive.CommunityTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.Repo
  alias Bright.Notifications.NotificationCommunity

  setup [:register_and_log_in_user]

  describe "render page" do
    test "renders page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/notifications/communities")

      assert html =~ "コミュニティからの通知"
      assert html =~ "コミュニティからの通知はありません"

      insert(:notification_community)

      {:ok, _lv, html} = live(conn, ~p"/notifications/communities")

      refute html =~ "コミュニティからの通知はありません"
    end
  end

  describe "render paginated notifications" do
    test "renders paginated notifications", %{conn: conn} do
      notification_communities =
        insert_list(11, :notification_community) |> Enum.sort_by(& &1.id) |> Enum.reverse()

      {:ok, lv, _html} = live(conn, ~p"/notifications/communities")

      notification_message_10 = notification_communities |> Enum.at(9) |> Map.get(:message)
      notification_message_11 = notification_communities |> Enum.at(10) |> Map.get(:message)

      assert lv |> has_element?("#notification_community_container span", notification_message_10)
      refute lv |> has_element?("#notification_community_container span", notification_message_11)

      lv |> element(~s{button[phx-click="next_button_click"]}) |> render_click()

      refute lv |> has_element?("#notification_community_container span", notification_message_10)
      assert lv |> has_element?("#notification_community_container span", notification_message_11)

      lv |> element(~s{button[phx-click="previous_button_click"]}) |> render_click()

      assert lv |> has_element?("#notification_community_container span", notification_message_10)
      refute lv |> has_element?("#notification_community_container span", notification_message_11)
    end
  end

  describe "notification modal and updating confirmed_at" do
    test "shows modal and updates confirmed_at", %{conn: conn} do
      notification_community = insert(:notification_community)

      {:ok, lv, _html} = live(conn, ~p"/notifications/communities")

      refute Repo.get(NotificationCommunity, notification_community.id).confirmed_at
      refute lv |> has_element?("#notification_community_modal")
      refute lv |> has_element?("#notification_community_modal", notification_community.detail)

      lv
      |> element(~s{div[phx-click="confirm_notification"]}, notification_community.message)
      |> render_click()

      assert Repo.get(NotificationCommunity, notification_community.id).confirmed_at
      assert lv |> has_element?("#notification_community_modal")
      assert lv |> has_element?("#notification_community_modal", notification_community.detail)
    end

    test "makes style font-bold to unconfirmed message", %{conn: conn} do
      notification_community = insert(:notification_community)

      {:ok, lv, _html} = live(conn, ~p"/notifications/communities")

      assert lv
             |> has_element?(
               "#notification_community_container span.font-bold",
               notification_community.message
             )
    end

    test "does not make style font-bold to confirmed message", %{conn: conn} do
      notification_community =
        insert(:notification_community, confirmed_at: NaiveDateTime.utc_now())

      {:ok, lv, _html} = live(conn, ~p"/notifications/communities")

      refute lv
             |> has_element?(
               "#notification_community_container span.font-bold",
               notification_community.message
             )
    end
  end
end
