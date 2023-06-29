defmodule BrightWeb.OnboardingLiveTest do
  use BrightWeb.ConnCase

  alias Bright.Accounts
  import Phoenix.LiveViewTest
  import Bright.Factory

  describe "Index" do
    setup %{conn: conn} do
      password = valid_user_password()

      {:ok, user} =
        params_for(:user_before_registration, password: password) |> Accounts.register_user()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    test "lists all onboardings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/onboardings")

      assert html =~ "Listing Onboardings"
    end
  end
end
