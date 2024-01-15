defmodule BrightWeb.SubscriptionLive.CreateFreeTrialFromSearchComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  def submit_trial_form(live) do
    params = %{
      free_trial_form: %{
        company_name: "dummy",
        phone_number: "0000000000",
        email: "test@example.com",
        pic_name: "dummy"
      }
    }

    live
    |> form("#free_trial_form_from_search", params)
    |> render_change()

    live
    |> form("#free_trial_form_from_search", params)
    |> render_submit()
  end

  # 「スキル検索」からの表示確認
  describe "shows on search_result page" do
    setup [:register_and_log_in_user]

    # データ準備: プラン
    setup do
      subscription_plan =
        insert(:subscription_plans, plan_code: "hr_plan")
        |> plan_with_plan_service_by_service_code("hr_basic")

      %{subscription_plan: subscription_plan}
    end

    # データ準備: スキル
    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)
      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

      career_field = insert(:career_field)
      job = insert(:job)
      insert(:career_field_job, career_field: career_field, job: job)
      insert(:job_skill_panel, job: job, skill_panel: skill_panel)

      %{
        skill_panel: skill_panel,
        skill_class: skill_class,
        skill: skill,
        career_field: career_field
      }
    end

    # データ準備: スキル保有者
    setup %{skill_class: skill_class, skill: skill} do
      user = insert(:user) |> insert_user_relations()
      insert(:skill_class_score, user: user, skill_class: skill_class)
      insert(:skill_score, user: user, skill: skill)
      :ok
    end

    # スキル検索フォームのサブミット
    def submit_search_form(live, career_field, skill_panel) do
      live
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{career_field: career_field.name_en}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "career_field"]})

      live
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{skill_panel: skill_panel.id}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "skill_panel"]})

      live
      |> form("#user_search_form",
        user_search: %{
          skills: %{
            0 => %{
              career_field: career_field.name_en,
              skill_panel: skill_panel.id
            }
          }
        }
      )
      |> render_submit()
    end

    test "open modal and recommend hr plan", %{
      conn: conn,
      career_field: career_field,
      skill_panel: skill_panel,
      subscription_plan: subscription_plan
    } do
      {:ok, live, _html} = live(conn, ~p"/mypage")
      submit_search_form(live, career_field, skill_panel)

      live
      |> element("a", "面談調整")
      |> render_click()

      assert live
             |> element("#free_trial_modal_from_search")
             |> render() =~ subscription_plan.name_jp

      submit_trial_form(live)

      # 申し込み後に改めてクリックした場合は無料トライアルモーダルは開かれない
      live
      |> element("a", "面談調整")
      |> render_click()

      refute has_element?(live, "#free_trial_modal_from_search")
    end
  end
end
