defmodule BrightWeb.OnboardingLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "Index" do
    test "lists all onboardings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/onboardings")

      assert html =~ "Listing Onboardings"
    end
  end
end
