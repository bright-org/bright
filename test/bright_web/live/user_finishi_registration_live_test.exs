defmodule BrightWeb.UserFinishRegistrationLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Show" do
    test "show page", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/users/finish_registration")

      assert html =~ "仮登録完了"
    end
  end
end
