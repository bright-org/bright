defmodule BrightWeb.OnboardingLiveTest do
  use BrightWeb.ConnCase

  alias Bright.Accounts
  import Phoenix.LiveViewTest
  import Bright.Factory
  import Bright.JobsFixtures

  describe "Index" do
    setup %{conn: conn} do
      career_field = career_field_fixture()
      job_fixture(%{career_field_id: career_field.id, rank: :basic})
      job_fixture(%{career_field_id: career_field.id, rank: :advanced})
      job_fixture(%{career_field_id: career_field.id, rank: :master})
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
