defmodule BrightWeb.NotificationLive.NotificationHeaderComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "render" do
    setup [:register_and_log_in_user]

    test "opens header", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      refute lv |> has_element?(~s{a[href="/notifications/operations"]})
      refute lv |> has_element?(~s{a[href="/notifications/communities"]})

      insert_list(1, :notification_operation)
      insert_list(1, :notification_community)

      assert lv |> element(~s{button[phx-click="toggle_notifications"]}) |> render_click()

      assert lv |> has_element?(~s{a[href="/notifications/operations"]})
      assert lv |> has_element?(~s{a[href="/notifications/communities"]})
    end
  end
end
