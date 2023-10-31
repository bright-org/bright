defmodule BrightWeb.NotificationLive.NotificationHeaderComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "render" do
    setup [:register_and_log_in_user]

    test "opens and loads unconfirmed notification counts", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      refute lv |> has_element?(~s{a[href="/notifications/operations"]})
      refute lv |> has_element?(~s{a[href="/notifications/communities"]})

      insert_list(3, :notification_operation)
      insert_list(2, :notification_community)

      assert lv |> element(~s{button[phx-click="toggle_notifications"]}) |> render_click()

      assert lv |> has_element?(~s{a[href="/notifications/operations"] span}, "3")
      assert lv |> has_element?(~s{a[href="/notifications/communities"] span}, "2")
    end
  end
end
