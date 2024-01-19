defmodule BrightWeb.SubscriptionLive.FreeTrialRecommendationComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  def submit_trial_form(live, params \\ %{}) do
    change_trial_form(live, params)

    live
    |> form("#free_trial_recommendation_form", params)
    |> render_submit()
  end

  def change_trial_form(live, params \\ %{}) do
    params = %{
      free_trial_form:
        %{
          company_name: "dummy",
          phone_number: "0000000000",
          email: "test@example.com",
          pic_name: "dummy"
        }
        |> Map.merge(params)
    }

    live
    |> form("#free_trial_recommendation_form", params)
    |> render_change()
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
             |> element("#free_trial_recommendation_modal")
             |> render() =~ subscription_plan.name_jp

      submit_trial_form(live)

      # 申し込み後に改めてクリックした場合は無料トライアルモーダルは開かれない
      live
      |> element("a", "面談調整")
      |> render_click()

      refute has_element?(live, "#free_trial_recommendation_modal")
    end
  end

  # 「チームを作る」からの表示確認
  describe "shows on teams page" do
    alias Bright.Teams

    # NOTE: swooshプロセスをglobalにしないと下記エラーが発生する
    #
    # refs:
    # - https://hexdocs.pm/swoosh/Swoosh.TestAssertions.html#set_swoosh_global/1
    # - https://github.com/swoosh/swoosh/pull/565/files
    #
    # ** (FunctionClauseError) no function clause matching in BrightWeb.MyTeamLive.handle_info/2
    # (bright 0.1.0) lib/bright_web/live/team_live/my_team_live.ex:134: BrightWeb.MyTeamLive.handle_info({:email, %Swoosh.Email{subject: "【Bright】無料トライアル の申し込みがありました", ...
    import Swoosh.TestAssertions
    setup :set_swoosh_global

    setup [:register_and_log_in_user]

    # データ準備: プラン
    setup do
      _dummy_same_limit_plan =
        insert(:subscription_plans,
          create_teams_limit: 1,
          team_members_limit: 5,
          free_trial_priority: 1
        )

      subscription_plan =
        insert(:subscription_plans,
          create_teams_limit: 2,
          team_members_limit: 7,
          free_trial_priority: 2
        )

      %{subscription_plan: subscription_plan}
    end

    def submit_team_form(live, name) do
      live
      |> form("#team_form", team: %{name: name})
      |> render_submit()
    end

    def submit_add_user(live, name) do
      insert(:user, name: name) |> insert_user_relations()

      live
      |> element("#search_word")
      |> render_change(%{search_word: name})

      live
      |> form("#add_user_form", %{})
      |> render_submit()
    end

    test "open modal when create_teams_limit is over", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      # 最初のチーム作成
      # プランなしでは1つは作成できるため、境界テストも含めて画面からチーム生成
      {:ok, live, _html} = live(conn, ~p"/teams/new")

      submit_team_form(live, "チーム1")
      assert team = Bright.Repo.get_by(Teams.Team, name: "チーム1")
      assert_redirect(live, "/teams/#{team.id}")

      # 2つ目のチーム作成（できない）
      {:ok, live, _html} = live(conn, ~p"/teams/new")
      submit_team_form(live, "チーム2")
      refute Bright.Repo.get_by(Teams.Team, name: "チーム2")

      # 無料トライアルモーダルが表示されること
      assert has_element?(live, "#free_trial_recommendation_modal")

      assert live
             |> element("#free_trial_recommendation_modal")
             |> render() =~ subscription_plan.name_jp

      # 無料トライアルの申し込み
      submit_trial_form(live)

      # 申し込み後は作成できること
      submit_team_form(live, "チーム2")
      assert team = Bright.Repo.get_by(Teams.Team, name: "チーム2")
      assert_redirect(live, "/teams/#{team.id}")
    end

    test "open modal when team_members_limit is over on creation", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      # 最初のチーム作成
      # プランなしでは5人までメンバーにできる。
      {:ok, live, _html} = live(conn, ~p"/teams/new")

      # チーム新規作成 メンバー超過
      submit_add_user(live, "user_2")
      submit_add_user(live, "user_3")
      submit_add_user(live, "user_4")
      submit_add_user(live, "user_5")
      submit_add_user(live, "user_6")

      # 無料トライアルモーダルが表示されること
      assert has_element?(live, "#free_trial_recommendation_modal")

      assert live
             |> element("#free_trial_recommendation_modal")
             |> render() =~ subscription_plan.name_jp

      # 無料トライアルの申し込み
      submit_trial_form(live)

      # 申し込み後は追加できること / 無料トライアルモーダルが表示されないこと
      submit_add_user(live, "user_6_2")

      refute has_element?(live, "#free_trial_recommendation_modal")
    end

    test "open modal when team_members_limit is over on update", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      {:ok, live, _html} = live(conn, ~p"/teams/new")

      # チーム新規作成
      submit_add_user(live, "user_2")
      submit_add_user(live, "user_3")
      submit_add_user(live, "user_4")
      submit_add_user(live, "user_5")
      submit_team_form(live, "チーム1")
      team = Bright.Repo.get_by(Teams.Team, name: "チーム1")

      # チーム編集画面で6人目を追加
      {:ok, live, _html} = live(conn, ~p"/teams/#{team}/edit")
      submit_add_user(live, "user_6")

      # 無料トライアルモーダルが表示されること
      assert has_element?(live, "#free_trial_recommendation_modal")

      assert live
             |> element("#free_trial_recommendation_modal")
             |> render() =~ subscription_plan.name_jp

      # 無料トライアルの申し込み
      submit_trial_form(live)

      # 申し込み後は追加できること / 無料トライアルモーダルが表示されないこと
      submit_add_user(live, "user_6_2")
      submit_add_user(live, "user_7")
      refute render(live) =~ "上限です"
      refute has_element?(live, "#free_trial_recommendation_modal")

      # 再度超えた場合は表示されること
      submit_add_user(live, "user_8")
      assert render(live) =~ "上限です"
    end

    test "NOT open modal if there is not satisfied plan", %{
      conn: conn,
      subscription_plan: subscription_plan
    } do
      Bright.Repo.delete(subscription_plan)

      {:ok, live, _html} = live(conn, ~p"/teams/new")

      submit_add_user(live, "user_2")
      submit_add_user(live, "user_3")
      submit_add_user(live, "user_4")
      submit_add_user(live, "user_5")
      submit_add_user(live, "user_6")

      # 無料トライアルモーダルが表示されないこと
      assert render(live) =~ "上限です"
      refute has_element?(live, "#free_trial_recommendation_modal")
    end
  end

  # フォーム仕様
  describe "Form" do
    setup [:register_and_log_in_user]

    # 無料トライアルモーダルを表示するための共通処理
    # チーム分析画面が容易に表示できるため使っている
    def show_component_modal(conn) do
      {:ok, live, _html} = live(conn, ~p"/teams/new")

      live
      |> form("#team_form", team: %{name: "チーム名1"})
      |> render_submit()

      # 2チーム目を作成するときに表示される
      {:ok, live, _html} = live(conn, ~p"/teams/new")

      live
      |> form("#team_form", team: %{name: "チーム名2"})
      |> render_submit()

      live
    end

    test "requires company_name when plan has team_up", %{
      conn: conn
    } do
      subscription_plan = insert(:subscription_plans, create_teams_limit: 2)

      insert(:subscription_plan_services,
        subscription_plan: subscription_plan,
        service_code: "team_up"
      )

      live = show_component_modal(conn)

      change_trial_form(live, %{company_name: ""})

      assert has_element?(live, "#free_trial_recommendation_form", "入力してください")
    end

    test "not requires company_name when plan hasnot team_up", %{
      conn: conn
    } do
      subscription_plan = insert(:subscription_plans, create_teams_limit: 2)

      insert(:subscription_plan_services,
        subscription_plan: subscription_plan,
        service_code: "not_team_up"
      )

      live = show_component_modal(conn)

      change_trial_form(live, %{company_name: ""})

      refute has_element?(live, "#free_trial_recommendation_form", "入力してください")
    end
  end
end
