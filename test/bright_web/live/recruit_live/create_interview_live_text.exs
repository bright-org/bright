defmodule BrightWeb.RecruitLive.CreateInterviewLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  import Swoosh.TestAssertions

  describe "create interview" do
    setup [:register_and_log_in_user]

    # データ準備: プラン
    setup do
      subscription_plan =
        insert(:subscription_plans, plan_code: "hr_plan")
        |> plan_with_plan_service_by_service_code("hr_basic")

      %{subscription_plan: subscription_plan}
    end

    # データ準備: チーム
    setup %{user: user} do
      team = insert(:hr_support_team)
      member = insert(:user) |> with_user_profile()
      insert(:team_member_users, team: team, user: user, is_admin: true)
      insert(:team_member_users, team: team, user: member)
      %{member: member}
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

    test "create new interview from skill search", %{
      conn: conn,
      career_field: career_field,
      skill_panel: skill_panel,
      member: member,
      user: user,
      subscription_plan: subscription_plan
    } do
      subscription_user_plan_subscribing_without_free_trial(user, subscription_plan)
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{career_field: career_field.name_en}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "career_field"]})

      lv
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{skill_panel: skill_panel.id}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "skill_panel"]})

      lv
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

      # 無料トライアルを開くクリックイベントになっていないか
      refute element(lv, "a", "面談調整") |> render() =~ "open_free_trial"

      lv
      |> element("a", "面談調整")
      |> render_click()

      # 選択した候補者で面談調整モーダルが開かれているか
      assert lv
             |> element("#create_interview_modal")
             |> render() =~ "データが表示できません"

      lv |> element("#create_interview_modal a", member.name) |> render_click()

      # 同席依頼先にメンバーが追加されているか
      assert lv
             |> element("#interview_form")
             |> render() =~ member.name

      {:ok, conn} =
        lv
        |> form("#interview_form",
          interview: %{
            comment: "イチオシ"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/recruits/interviews")

      assert conn.resp_body =~ "面談調整中"

      assert_email_sent(fn email ->
        assert email.from == {"Brightカスタマーサクセス", "agent@bright-fun.org"}
        assert email.subject == "【Bright】面談参加依頼が届いています"
      end)
    end

    test "open create interview modal when member at hr team, no subscrption", %{
      conn: conn,
      career_field: career_field,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{career_field: career_field.name_en}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "career_field"]})

      lv
      |> form("#user_search_form",
        user_search: %{
          skills: %{0 => %{skill_panel: skill_panel.id}}
        }
      )
      |> render_change(%{_target: ["user_search", "skills", "0", "skill_panel"]})

      lv
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

      # 無料トライアルを開くクリックイベントになっていないか
      refute element(lv, "a", "面談調整") |> render() =~ "open_free_trial"
    end
  end
end
