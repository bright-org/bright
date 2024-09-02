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
        |> follow_redirect(conn, "/teams/new")

      assert conn.resp_body =~ "オンボーディングをスキップしました"
    end
  end

  describe "onboarding" do
    setup [:register_and_log_in_user_not_onboarding]

    setup %{user: user} do
      sk = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: sk, class: 1)
      insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      cf = insert(:career_field)

      job = insert(:job)
      insert(:career_field_job, career_field_id: cf.id, job_id: job.id)
      insert(:job_skill_panel, job_id: job.id, skill_panel_id: sk.id)

      %{job: job, user: user, skill_panel: sk}
    end

    test "show job's skill_panel", %{job: job, skill_panel: skill_panel, conn: conn} do
      {:ok, lv, html} =
        live(conn, ~p"/onboardings/#{job.id}?career_field=engineer")

      assert html =~ "some job"

      lv
      |> element("#select_skill")
      |> render_click()
      |> follow_redirect(conn, ~p"/more_skills/#{skill_panel.id}")

      assert Bright.Repo.aggregate(Bright.Onboardings.UserOnboarding, :count) == 1
    end
  end

  describe "select_skill" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      sk = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: sk, class: 1)
      insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      cf = insert(:career_field)

      job = insert(:job)
      insert(:career_field_job, career_field_id: cf.id, job_id: job.id)
      insert(:job_skill_panel, job_id: job.id, skill_panel_id: sk.id)

      %{job: job, user: user, skill_panel: sk}
    end

    test "show skill_panel input page", %{skill_panel: skill_panel, conn: conn} do
      {:ok, _lv, html} =
        live(conn, ~p"/more_skills/#{skill_panel.id}")

      assert html =~ skill_panel.name
    end
  end
end
