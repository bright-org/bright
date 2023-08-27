defmodule BrightWeb.OnboardingLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    setup [:register_and_log_in_user_not_onboarding]

    test "skip onboardings", %{conn: conn} do
      {:ok, index_live, html} = live(conn, ~p"/onboardings")

      assert html =~ "オンボーディング"

      {:ok, conn} =
        index_live
        |> element("#skip_onboarding")
        |> render_click()
        |> follow_redirect(conn, "/teams")

      assert conn.resp_body =~ "オンボーディングをスキップしました"
    end
  end
end
