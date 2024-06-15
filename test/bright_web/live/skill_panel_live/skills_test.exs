defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Bright.Repo
  alias Bright.UserJobProfiles
  alias Bright.SkillScores.SkillClassScore
  alias Bright.SkillScores.SkillClassScoreLog
  alias Bright.Teams.TeamMemberUsers
  alias Bright.CustomGroups.CustomGroupMemberUser

  defp setup_skills(%{user: user, score: score}) do
    insert_user_skill_panel(user, score)
  end

  defp insert_user_skill_panel(user, score) do
    skill_panel = insert(:skill_panel)
    insert(:user_skill_panel, user: user, skill_panel: skill_panel)
    skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

    skill_unit =
      insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

    [%{skills: [skill_1, skill_2, skill_3]} = skill_category] =
      insert_skill_categories_and_skills(skill_unit, [3])

    if score do
      insert(:init_skill_class_score, user: user, skill_class: skill_class)
      _skill_unit_score = insert(:skill_unit_score, user: user, skill_unit: skill_unit)
      insert(:skill_score, user: user, skill: skill_1, score: score)
      insert(:skill_score, user: user, skill: skill_2)
      # skill_3 スコアを意図的に未作成
      # insert(:skill_score, user: user, skill: skill_3)
    end

    %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill_unit: skill_unit,
      skill_category: skill_category,
      skill_1: skill_1,
      skill_2: skill_2,
      skill_3: skill_3
    }
  end

  # 共通処理: 入力開始
  defp start_edit(show_live) do
    show_live
    |> element("#link-skills-form")
    |> render_click()
  end

  # 共通処理: 入力完了
  defp submit_form(show_live) do
    show_live
    |> element(~s{button[phx-click="submit"]})
    |> render_click()
  end

  describe "Show" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      %{skill_panel: skill_panel, skill_class: skill_class, skill_class_2: skill_class_2}
    end

    test "shows content", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}")

      assert html =~ "スキルパネル"
      assert has_element?(show_live, "#class_tab_1", "クラス1")
      assert has_element?(show_live, "#class_tab_2", "クラス2")
    end

    test "shows content without parameters", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels")

      assert html =~ skill_panel.name
      assert has_element?(show_live, "#class_tab_1", "クラス1")
    end

    test "shows skills table", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      [skill_unit_1, skill_unit_2] =
        insert_list(2, :skill_unit)
        |> Enum.with_index(1)
        |> Enum.map(fn {skill_unit, position} ->
          insert(:skill_class_unit,
            skill_class: skill_class,
            skill_unit: skill_unit,
            position: position
          )

          skill_unit
        end)

      skill_unit_dummy = insert(:skill_unit, name: "紐づいていないダミー")

      skill_categories = insert_skill_categories_and_skills(skill_unit_1, [1, 1, 1])
      insert_skill_categories_and_skills(skill_unit_2, [1, 1, 2])
      insert_skill_categories_and_skills(skill_unit_dummy, [1])

      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}")

      assert html =~ "スキルパネル"

      # 知識エリアの表示確認
      assert show_live
             |> element(~s{td[id="unit-1"][rowspan="3"]}, skill_unit_1.name)
             |> has_element?()

      assert show_live
             |> element(~s{td[id="unit-2"][rowspan="4"]}, skill_unit_2.name)
             |> has_element?()

      refute html =~ skill_unit_dummy.name

      # カテゴリおよびスキルの表示確認
      skill_categories
      |> Enum.each(fn skill_category ->
        rowspan = length(skill_category.skills)

        assert show_live
               |> element(~s{td[rowspan="#{rowspan}"]}, skill_category.name)
               |> has_element?()

        skill_category.skills
        |> Enum.each(fn skill ->
          assert show_live |> element("td", skill.name) |> has_element?()
        end)
      end)
    end

    test "shows when skill_score is missing", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit, position: 1)

      # ２つのスキルのうち、１つのみスキルスコアを生成
      [%{skills: [skill_1, _skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:full_mark_skill_score, user: user, skill: skill_1)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}")

      # ドーナツグラフまわりの表記
      assert has_element?(show_live, ~s{#profile_score_stats}, "平均")
      assert has_element?(show_live, ~s{#profile_score_stats .evidence_percentage}, "50%")
      assert has_element?(show_live, ~s{#profile_score_stats .reference_percentage}, "50%")
      assert has_element?(show_live, ~s{#profile_score_stats .exam_percentage}, "50%")

      # スキル一覧
      assert has_element?(show_live, ~s{#skill-2 .score-mark-low})
    end

    test "shows the skill class by query string parameter", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=2")
      assert has_element?(show_live, ~s(#class_tab_2 a[aria-current="page"]))
    end

    test "switches skill class and creates the score on access", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class_2: skill_class_2
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}")

      refute Repo.get_by(SkillClassScore,
               user_id: user.id,
               skill_class_id: skill_class_2.id
             )

      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class_2.id, position: 1}])

      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      insert(:skill_score, user: user, skill: skill, score: :high)

      show_live
      |> element("#class_tab_2 a")
      |> render_click()

      assert has_element?(show_live, ~s(#class_tab_2 a[aria-current="page"]))

      assert Repo.get_by(SkillClassScore,
               user_id: user.id,
               skill_class_id: skill_class_2.id
             )

      # スキルクラススコアのログ作成確認
      assert %{percentage: 100.0} =
               Repo.get_by(SkillClassScoreLog, %{
                 user_id: user.id,
                 skill_class_id: skill_class_2.id,
                 date: Date.utc_today()
               })
    end

    test "shows star", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}")

      assert html =~
               ~s{class="bg-white border border-brightGreen-500 rounded px-1 h-8 flex items-center mt-auto mb-1 hover:filter hover:brightness-95"}

      html =
        show_live
        |> element(~s{button[phx-click="click_star_button"]})
        |> render_click()

      assert html =~
               ~s{class="bg-white border border-brightGreen-300 rounded px-1 h-8 flex items-center mt-auto mb-1 hover:filter hover:brightness-95"}

      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}")

      assert html =~
               ~s{class="bg-white border border-brightGreen-300 rounded px-1 h-8 flex items-center mt-auto mb-1 hover:filter hover:brightness-95"}

      html =
        show_live
        |> element(~s{button[phx-click="click_star_button"]})
        |> render_click()

      assert html =~
               ~s{class="bg-white border border-brightGreen-500 rounded px-1 h-8 flex items-center mt-auto mb-1 hover:filter hover:brightness-95"}
    end
  end

  describe "Show no skill panel" do
    setup [:register_and_log_in_user]

    test "shows content with no skill panel message", %{conn: conn} do
      {:ok, show_live, html} = live(conn, ~p"/panels")

      assert html =~ "スキルパネルがありません"

      show_live
      |> element("a", "スキルを選ぶ")
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/onboardings"
    end
  end

  # # TODO: 時間操作の対応
  # describe "Show latest skill panel" do
  #   setup [:register_and_log_in_user]
  #
  #   setup %{user: user} do
  #     [skill_panel_1, skill_panel_2] =
  #       insert_pair(:skill_panel)
  #       |> Enum.map(fn skill_panel ->
  #         insert(:user_skill_panel, user: user, skill_panel: skill_panel)
  #         insert(:skill_class, skill_panel: skill_panel, class: 1)
  #         skill_panel
  #       end)
  #
  #     %{skill_panel_1: skill_panel_1, skill_panel_2: skill_panel_2}
  #   end
  #
  #   test "switches latest skill panel by access", %{
  #     skill_panel_1: skill_panel_1,
  #     skill_panel_2: skill_panel_2,
  #     conn: conn
  #   } do
  #     {:ok, _show_live, html} = live(conn, ~p"/panels/#{skill_panel_1}")
  #     assert html =~ "スキルパネル / #{skill_panel_1.name}"
  #     {:ok, _show_live, html} = live(conn, ~p"/panels")
  #     assert html =~ "スキルパネル / #{skill_panel_1.name}"
  #
  #     :timer.sleep(1000)
  #     {:ok, _show_live, html} = live(conn, ~p"/panels/#{skill_panel_2}")
  #     assert html =~ "スキルパネル / #{skill_panel_2.name}"
  #     {:ok, _show_live, html} = live(conn, ~p"/panels")
  #     assert html =~ "スキルパネル / #{skill_panel_2.name}"
  #   end
  # end

  describe "Show skill scores" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: :low
    test "shows mark when score: low", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live
             |> element(".score-mark-low")
             |> has_element?()
    end

    @tag score: :middle
    test "shows mark when score: middle", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live
             |> element(".score-mark-middle")
             |> has_element?()
    end

    @tag score: :high
    test "shows mark when score: high", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live
             |> element(".score-mark-high")
             |> has_element?()
    end
  end

  # 対象者切り替え
  describe "Megamenu related users" do
    setup [:register_and_log_in_user, :setup_skills]

    setup %{skill_panel: skill_panel, skill_class: skill_class} do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:init_skill_class_score, user: user_2, skill_class: skill_class)

      %{user_2: user_2}
    end

    @tag score: :low
    test "redirects team member page", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(~s{#related-user-card-related_user a[phx-value-tab_name="team"]})
      |> render_click()

      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_menu"]}, user_2.name)
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/panels/#{skill_panel.id}/#{user_2.name}"
    end

    @tag score: :low
    test "redirects custom_group member page", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      custom_group = insert(:custom_group, user: user)
      insert(:custom_group_member_user, user: user_2, custom_group: custom_group)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(~s{#related-user-card-related_user a[phx-value-tab_name="custom_group"]})
      |> render_click()

      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_menu"]}, user_2.name)
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/panels/#{skill_panel.id}/#{user_2.name}"
    end

    @tag score: :low
    test "redirects candidated user page", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      insert(:recruitment_stock_user, recruiter: user, user: user_2)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(
        ~s{#related-user-card-related_user a[phx-value-tab_name="candidate_for_employment"]}
      )
      |> render_click()

      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_menu"]})
      |> render_click()

      {path, _} = assert_redirect(show_live)

      # 匿名用エンコードの時刻参照でずれが起きるため、パスを簡易的に確認
      assert String.starts_with?(path, "/panels/#{skill_panel.id}/anon/")
    end

    @tag score: :low
    test "shows clear_display_user button", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      refute has_element?(show_live, ~s{button[phx-click="clear_display_user"]})

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/#{user_2.name}")

      show_live
      |> element(~s{button[phx-click="clear_display_user"]})
      |> render_click()

      {path, _} = assert_redirect(show_live)
      assert path == "/panels/#{skill_panel.id}"
    end
  end

  describe "Input skill score item score" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: :low
    test "update scores", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      # skill_1
      # lowからlowのキャンセル操作相当
      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      show_live
      |> element(~s{#skill-2-form label[phx-value-score="middle"]})
      |> render_click()

      show_live
      |> element(~s{#skill-3-form label[phx-value-score="high"]})
      |> render_click()

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      refute has_element?(show_live, "#skills-form")

      # 永続化確認のための再描画
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, "#skill-1 .score-mark-low")
      assert has_element?(show_live, "#skill-2 .score-mark-middle")
      assert has_element?(show_live, "#skill-3 .score-mark-high")

      # スキルクラススコアのログ作成確認
      skill_class_score_log =
        Repo.get_by(SkillClassScoreLog, %{
          user_id: user.id,
          skill_class_id: skill_class.id,
          date: Date.utc_today()
        })

      assert round(skill_class_score_log.percentage) == 33
    end

    @tag score: nil
    test "edits by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      # 1を押してスコアを設定する。以下、2, 3と続く
      # 最終行は押してもそのままフォーカスした状態を継続する
      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      refute has_element?(show_live, ~s{#skill-1-form [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-2-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "2"})

      refute has_element?(show_live, ~s{#skill-2-form [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      assert has_element?(show_live, ~s{#skill-3-form [phx-window-keydown="shortcut"]})

      submit_form(show_live)
      {path, _flash} = assert_redirect(show_live)
      assert path == ~p"/graphs/#{skill_panel}?class=1"

      # 永続化確認のための再描画
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, "#skill-1 .score-mark-high")
      assert has_element?(show_live, "#skill-2 .score-mark-middle")
      assert has_element?(show_live, "#skill-3 .score-mark-low")
    end

    @tag score: nil
    test "move by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      # ↓、Enter、↑による移動
      # 最初と最終行は押してもそのままフォーカスした状態を継続する
      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowUp"})

      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowDown"})

      refute has_element?(show_live, ~s{#skill-1-form [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-2-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "Enter"})

      refute has_element?(show_live, ~s{#skill-2-form [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowDown"})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowUp"})

      refute has_element?(show_live, ~s{#skill-3-form [phx-window-keydown="shortcut"]})

      submit_form(show_live)
      {path, _flash} = assert_redirect(show_live)
      assert path == ~p"/graphs/#{skill_panel}?class=1"
    end
  end

  describe "Shows skill score percentages" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows updated value", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 初期表示
      assert has_element?(show_live, ".score-high-percentage", "0％")
      assert has_element?(show_live, ".score-middle-percentage", "0％")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      assert has_element?(show_live, "#skill_gem_in_skills_form", "見習い")
      assert has_element?(show_live, "#skill_gem_in_skills_form .score-high-percentage", "0％")

      assert has_element?(
               show_live,
               "#skill_gem_in_skills_form .score-middle-percentage",
               "0％"
             )

      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      show_live
      |> element(~s{#skill-2-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "2"})

      assert has_element?(show_live, "#skill_gem_in_skills_form", "ベテラン")

      assert has_element?(
               show_live,
               "#skill_gem_in_skills_form .score-high-percentage",
               "66％"
             )

      assert has_element?(
               show_live,
               "#skill_gem_in_skills_form .score-middle-percentage",
               "34％"
             )

      data = [[66]] |> Jason.encode!()
      assert has_element?(show_live, ~s(#skills-form-gem[data-data='#{data}']))

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, ".score-high-percentage", "66％")
      assert has_element?(show_live, ".score-middle-percentage", "34％")

      # 各スキルスコアの削除（lowにする操作）と、習得率表示更新
      start_edit(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-2-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      assert has_element?(show_live, "#skill_gem_in_skills_form", "見習い")
      assert has_element?(show_live, "#skill_gem_in_skills_form .score-high-percentage", "0％")

      assert has_element?(
               show_live,
               "#skill_gem_in_skills_form .score-middle-percentage",
               "0％"
             )

      data = [[0]] |> Jason.encode!()
      assert has_element?(show_live, ~s(#skills-form-gem[data-data='#{data}']))

      submit_form(show_live)
      refute has_element?(show_live, "#skills-form")

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, ".score-high-percentage", "0％")
      assert has_element?(show_live, ".score-middle-percentage", "0％")
    end
  end

  # 対象者の切り替え
  describe "Display user" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "clear display_user", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      # 対象者用意
      user_2 = insert(:user)
      skill_panel_2 = insert(:skill_panel)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel_2)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel_2, class: 1)
      insert(:skill_class_score, user: user_2, skill_class: skill_class_2)
      encrypted_name = BrightWeb.DisplayUserHelper.encrypt_user_name(user_2)

      # 対象者へアクセス
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel_2}/anon/#{encrypted_name}")

      assert show_live
             |> element("#profile-skill-panel-name")
             |> render() =~ skill_panel_2.name

      # 自分に戻す
      {:ok, show_live, _html} =
        show_live
        |> element("button", "自分に戻す")
        |> render_click()
        |> follow_redirect(conn)

      assert show_live
             |> element("#profile-skill-panel-name")
             |> render() =~ skill_panel.name
    end
  end

  # エビデンス登録
  # see: ./skill_evident_component_test.ex

  # 教材
  describe "Skill reference area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal case: skill_score NOT existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      skill_reference = insert(:skill_reference, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-reference")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/reference?class=1")
      assert render(show_live) =~ skill_1.name

      assert has_element?(
               show_live,
               ~s(iframe#iframe-skill-reference[src="#{skill_reference.url}"])
             )
    end

    @tag score: :low
    test "shows modal case: skill_score existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      skill_reference = insert(:skill_reference, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-reference")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/reference?class=1")
      assert render(show_live) =~ skill_1.name

      assert has_element?(
               show_live,
               ~s(iframe#iframe-skill-reference[src="#{skill_reference.url}"])
             )
    end

    @tag score: nil
    test "教材がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute has_element?(show_live, "#skill-1 .link-reference")
    end

    @tag score: nil
    test "教材のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_reference, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute has_element?(show_live, "#skill-1 .link-reference")
    end
  end

  # 試験
  describe "Skill exam area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal case: skill_score NOT existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      skill_exam = insert(:skill_exam, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-exam")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/exam?class=1")
      assert render(show_live) =~ skill_1.name
      assert has_element?(show_live, ~s(iframe#iframe-skill-exam[src="#{skill_exam.url}"]))
    end

    @tag score: :low
    test "shows modal case: skill_score existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      skill_exam = insert(:skill_exam, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-exam")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/exam?class=1")
      assert render(show_live) =~ skill_1.name
      assert has_element?(show_live, ~s(iframe#iframe-skill-exam[src="#{skill_exam.url}"]))
    end

    @tag score: nil
    test "試験がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute has_element?(show_live, "#skill-1 .link-exam")
    end

    @tag score: nil
    test "試験のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_exam, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute has_element?(show_live, "#skill-1 .link-exam")
    end
  end

  # タイムライン切り替え
  describe "Timeline bar" do
    alias BrightWeb.TimelineHelper
    setup [:register_and_log_in_user, :setup_skills]

    setup do
      timeline = TimelineHelper.get_current()
      %{labels: labels} = TimelineHelper.shift_for_past(timeline)
      past_label = List.last(labels)
      past_date = TimelineHelper.label_to_date(past_label)

      %{timeline: timeline, past_label: past_label, past_date: past_date}
    end

    # 過去分のデータ用意
    setup %{
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill_unit: skill_unit,
      skill_category: skill_category,
      skill_1: skill_1,
      past_date: past_date
    } do
      locked_date = TimelineHelper.get_shift_date_from_date(past_date, -1)

      h_skill_class =
        insert(:historical_skill_class,
          skill_panel_id: skill_panel.id,
          locked_date: locked_date,
          class: 1,
          trace_id: skill_class.trace_id
        )

      h_skill_unit =
        insert(:historical_skill_unit,
          locked_date: locked_date,
          trace_id: skill_unit.trace_id
        )

      insert(:historical_skill_class_unit,
        historical_skill_class: h_skill_class,
        historical_skill_unit: h_skill_unit,
        position: 1
      )

      h_skill_category =
        insert(:historical_skill_category,
          trace_id: skill_category.trace_id,
          historical_skill_unit: h_skill_unit
        )

      h_skill_1 =
        insert(:historical_skill,
          trace_id: skill_1.trace_id,
          historical_skill_category: h_skill_category,
          position: 1
        )

      # 現在にはないスキルとして用意
      h_skill_x =
        insert(:historical_skill, historical_skill_category: h_skill_category, position: 2)

      # スキルスコアがないスキルとして用意
      insert(:historical_skill, historical_skill_category: h_skill_category, position: 3)

      # ユーザーのスコアの用意
      insert(:historical_skill_class_score,
        historical_skill_class: h_skill_class,
        user: user,
        locked_date: past_date
      )

      insert(:historical_skill_score, historical_skill: h_skill_1, user: user, score: :middle)
      insert(:historical_skill_score, historical_skill: h_skill_x, user: user, score: :high)

      %{
        locked_date: locked_date,
        historical_skill_class: h_skill_class,
        historical_skill_unit: h_skill_unit
      }
    end

    @tag score: :high
    test "shows past skills", %{
      conn: conn,
      skill_panel: skill_panel,
      past_label: past_label
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}")

      show_live
      |> element("button", past_label)
      |> render_click()

      assert has_element?(show_live, "#skill-1 .score-mark-middle")
      assert has_element?(show_live, "#skill-2 .score-mark-high")
      assert has_element?(show_live, "#skill-3 .score-mark-low")
      assert has_element?(show_live, "#my-percentages .score-high-percentage", "33％")
      assert has_element?(show_live, "#my-percentages .score-middle-percentage", "34％")
    end

    @tag score: nil
    test "shows historical_skill_units in order", %{
      conn: conn,
      skill_panel: skill_panel,
      historical_skill_class: h_skill_class,
      locked_date: locked_date,
      past_label: past_label
    } do
      [h_skill_unit_2, h_skill_unit_3] =
        insert_pair(:historical_skill_unit, locked_date: locked_date)

      [{h_skill_unit_2, 3}, {h_skill_unit_3, 2}]
      |> Enum.each(fn {h_skill_unit, position} ->
        insert(:historical_skill,
          historical_skill_category:
            build(:historical_skill_category, historical_skill_unit: h_skill_unit),
          position: 1
        )

        insert(:historical_skill_class_unit,
          historical_skill_class: h_skill_class,
          historical_skill_unit: h_skill_unit,
          position: position
        )
      end)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}")

      show_live
      |> element("button", past_label)
      |> render_click()

      assert show_live
             |> element("#unit-2")
             |> render() =~ h_skill_unit_3.name

      assert show_live
             |> element("#unit-3")
             |> render() =~ h_skill_unit_2.name
    end
  end

  # 他者との比較
  describe "Compared User" do
    setup [:register_and_log_in_user, :setup_skills]

    # 他者 user_2 用意
    setup %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill_1: skill_1
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:skill_score, user: user_2, skill: skill_1, score: :high)
      insert(:init_skill_class_score, user: user_2, skill_class: skill_class)

      %{user_2: user_2}
    end

    # 他者とのチーム関連付け
    setup %{user: user, user_2: user_2} do
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)
      %{team: team}
    end

    @tag score: :low
    test "shows compared user skills percentage", %{
      conn: conn,
      skill_panel: skill_panel,
      user_2: user_2
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 「個人とスキルを比較」 チームタブ選択
      show_live
      |> element(~s{#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]})
      |> render_click()

      # 対象ユーザー選択
      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_compare"]}, user_2.name)
      |> render_click()

      assert has_element?(show_live, "#skills-table-field", user_2.name)
      assert has_element?(show_live, "#user-1-percentages .score-middle-percentage", "0％")
      assert has_element?(show_live, "#user-1-percentages .score-high-percentage", "33％")
    end

    @tag score: :low
    test "access control, not shows unauthorized user", %{
      conn: conn,
      skill_panel: skill_panel,
      team: team,
      user_2: user_2
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 「個人とスキルを比較」 チームタブ選択
      show_live
      |> element(~s{#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]})
      |> render_click()

      # user_2をチームから除外して参照不可状況をつくっている
      # テスト便宜上、画面を出してから削除している
      Repo.get_by(TeamMemberUsers, team_id: team.id, user_id: user_2.id) |> Repo.delete!()

      # 対象ユーザー選択
      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_compare"]}, user_2.name)
      |> render_click()

      refute has_element?(show_live, "#skills-table-field", user_2.name)
    end
  end

  # チーム全員との比較
  describe "Compared team" do
    setup [:register_and_log_in_user, :setup_skills]

    # 他者用意
    setup %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill_1: skill_1
    } do
      [user_2, user_3] =
        1..2
        |> Enum.map(fn _ ->
          user = insert(:user) |> with_user_profile()
          insert(:user_skill_panel, user: user, skill_panel: skill_panel)
          insert(:skill_score, user: user, skill: skill_1, score: :high)
          insert(:init_skill_class_score, user: user, skill_class: skill_class)
          user
        end)

      %{user_2: user_2, user_3: user_3}
    end

    # 他者とのチーム関連付け
    setup %{user: user, user_2: user_2, user_3: user_3} do
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)
      insert(:team_member_users, user: user_3, team: team)

      # 招待が終わっていないメンバーをダミーとして追加
      user_dummy = insert(:user)
      insert(:team_member_users, user: user_dummy, team: team, invitation_confirmed_at: nil)

      %{team: team}
    end

    @tag score: :low
    test "shows compared team member skills percentage", %{
      conn: conn,
      skill_panel: skill_panel,
      team: team,
      user_2: user_2,
      user_3: user_3
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 「チーム全員と比較」 チームタブ選択
      show_live
      |> element(
        ~s{#related-team-card-tabrelated-team_card-compare a[phx-value-tab_name="joined_teams"]}
      )
      |> render_click()

      # 対象チーム選択
      show_live
      |> element(~s{li[phx-click="on_card_row_click"]}, team.name)
      |> render_click()

      assert has_element?(show_live, "#skills-table-field", user_2.name)
      assert has_element?(show_live, "#skills-table-field", user_3.name)
      assert has_element?(show_live, "#user-1-percentages .score-high-percentage", "33％")
      assert has_element?(show_live, "#user-2-percentages .score-high-percentage", "33％")

      # 招待済みでない3人目がいないこと
      refute has_element?(show_live, "#user-3-percentages")
    end

    @tag score: :low
    test "shows by query parameter", %{
      conn: conn,
      skill_panel: skill_panel,
      team: team,
      user: user,
      user_2: user_2,
      user_3: user_3
    } do
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)
      insert(:skill_class_score, user: user, skill_class: skill_class_2)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1&team=#{team.id}")

      assert has_element?(show_live, "#skills-table-field", user_2.name)
      assert has_element?(show_live, "#skills-table-field", user_3.name)
      assert has_element?(show_live, "#user-1-percentages .score-high-percentage", "33％")
      assert has_element?(show_live, "#user-2-percentages .score-high-percentage", "33％")
      refute has_element?(show_live, "#user-3-percentages")

      # 比較対象を変更してクラス切り替えで再初期化されないこと
      show_live
      |> element(~s(button[phx-click="reject_compared_user"][phx-value-name="#{user_3.name}"]))
      |> render_click()

      show_live
      |> element("#class_tab_2 a")
      |> render_click()

      refute has_element?(show_live, "#user-2-percentages")
    end

    @tag score: :low
    test "access control, not shows unauthorized team", %{
      conn: conn,
      skill_panel: skill_panel,
      team: team,
      user: user,
      user_2: user_2
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 「チーム全員と比較」 チームタブ選択
      show_live
      |> element(
        ~s{#related-team-card-tabrelated-team_card-compare a[phx-value-tab_name="joined_teams"]}
      )
      |> render_click()

      # 自身をteamから除外して参照不可状況をつくっている
      # テスト便宜上、画面を出してから削除している
      Repo.get_by(TeamMemberUsers, team_id: team.id, user_id: user.id) |> Repo.delete!()

      # 対象チーム選択
      show_live
      |> element(~s{li[phx-click="on_card_row_click"]}, team.name)
      |> render_click()

      refute has_element?(show_live, "#skills-table-field", user_2.name)
    end

    @tag score: :low
    test "access control, not shows unauthorized team by query parameter", %{
      conn: conn,
      skill_panel: skill_panel,
      team: team,
      user: user,
      user_2: user_2
    } do
      # 自身をteamから除外して参照不可状況をつくっている
      Repo.get_by(TeamMemberUsers, team_id: team.id, user_id: user.id) |> Repo.delete!()
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1&team=#{team.id}")

      refute has_element?(show_live, "#skills-table-field", user_2.name)
    end
  end

  # カスタムグループ
  describe "Custom group" do
    setup [:register_and_log_in_user, :setup_skills]

    # 他者とのチーム関連付け
    setup %{user: user} do
      [user_2, user_3] = users = insert_pair(:user) |> Enum.map(&with_user_profile/1)
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)
      insert(:team_member_users, user: user_3, team: team)

      %{users: users, team: team}
    end

    defp add_user_to_list(show_live, user) do
      show_live
      |> element(~s{#related-user-card-related-user-card-compare a[phx-value-tab_name="team"]})
      |> render_click()

      show_live
      |> element(~s{a[phx-click="click_on_related_user_card_compare"]}, user.name)
      |> render_click()
    end

    @tag score: nil
    test "creates new custom_group", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      users: [user_2, _user_3]
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      add_user_to_list(show_live, user_2)

      show_live
      |> form("#form-custom-group-create", %{custom_group: %{name: "テスト"}})
      |> render_submit()

      assert has_element?(show_live, "#selected-custom-group-name", "テスト")

      %{custom_groups: [custom_group]} = Repo.preload(user, custom_groups: [:member_users])
      [member_user] = custom_group.member_users
      assert custom_group.name == "テスト"
      assert member_user.user_id == user_2.id
    end

    @tag score: nil
    test "anonymous users cannot be added", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      # 採用候補者の用意
      user_4 = insert(:user) |> with_user_profile()
      insert(:recruitment_stock_user, recruiter: user, user: user_4)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(
        ~s{#related-user-card-related-user-card-compare a[phx-value-tab_name="candidate_for_employment"]}
      )
      |> render_click()

      show_live
      |> element(
        ~s{#related-user-card-related-user-card-compare a[phx-click="click_on_related_user_card_compare"]}
      )
      |> render_click()

      show_live
      |> form("#form-custom-group-create", %{custom_group: %{name: "テスト"}})
      |> render_submit()

      %{custom_groups: [custom_group]} = Repo.preload(user, custom_groups: [:member_users])
      assert [] == custom_group.member_users
      assert custom_group.name == "テスト"
    end

    @tag score: nil
    test "shows members", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      users: [user_2, user_3]
    } do
      custom_group =
        insert(:custom_group,
          user: user,
          member_users: [build(:custom_group_member_user, user: user_2)]
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      add_user_to_list(show_live, user_3)

      show_live
      |> element(
        ~s(#custom-groups-list-dropdown div[phx-click="select"][phx-value-name="#{custom_group.name}"])
      )
      |> render_click()

      assert has_element?(show_live, "#skills-table-field", user_2.name)
      refute has_element?(show_live, "#skills-table-field", user_3.name)
    end

    @tag score: nil
    test "not shows member already unrelated", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      users: [user_2, _user_3],
      team: team
    } do
      # チームメンバーからuser_2を削除して、関係を解消している
      custom_group =
        insert(:custom_group,
          user: user,
          member_users: [build(:custom_group_member_user, user: user_2)]
        )

      member_user = Repo.get_by!(TeamMemberUsers, team_id: team.id, user_id: user_2.id)
      Repo.delete(member_user)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(
        ~s(#custom-groups-list-dropdown div[phx-click="select"][phx-value-name="#{custom_group.name}"])
      )
      |> render_click()

      refute has_element?(show_live, "#skills-table-field", user_2.name)

      refute Repo.get_by(CustomGroupMemberUser,
               custom_group_id: custom_group.id,
               user_id: user_2.id
             )
    end

    @tag score: nil
    test "updates custom_group name", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      custom_group = insert(:custom_group, user: user, name: "更新前")

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(
        ~s(#custom-groups-list-dropdown div[phx-click="select"][phx-value-name="#{custom_group.name}"])
      )
      |> render_click()

      show_live
      |> element("#btn-custom-group-update")
      |> render_click()

      show_live
      |> form("#form-custom-group-update", %{custom_group: %{name: "更新後"}})
      |> render_submit()

      assert has_element?(show_live, "#selected-custom-group-name", "更新後")

      %{custom_groups: [custom_group]} = Repo.preload(user, :custom_groups)
      assert custom_group.name == "更新後"
    end

    @tag score: nil
    test "deletes custom_group", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      users: [user_2, _user_3]
    } do
      custom_group =
        insert(:custom_group,
          user: user,
          member_users: [build(:custom_group_member_user, user: user_2)]
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element(
        ~s(#custom-groups-list-dropdown div[phx-click="select"][phx-value-name="#{custom_group.name}"])
      )
      |> render_click()

      show_live
      |> element("#btn-custom-group-delete")
      |> render_click()

      refute has_element?(show_live, "#selected-custom-group-name")
      assert %{custom_groups: []} = Repo.preload(user, :custom_groups)
    end
  end

  # 案内メッセージ
  describe "Messages" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows first skills edit message", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      assert has_element?(show_live, "#help-enter-skills")

      # 入力後に表示されないことの確認
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="middle"]})
      |> render_click()

      submit_form(show_live)
      {path, flash} = assert_redirect(show_live)
      assert path == ~p"/graphs/#{skill_panel}?class=1"
      assert flash["first_submit_in_overall"]

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      refute has_element?(show_live, "#help-enter-skills")
    end

    @tag score: nil
    test "shows first time submit message", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      {path, flash} = assert_redirect(show_live)
      assert path == ~p"/graphs/#{skill_panel}?class=1"
      assert flash["first_submit_in_overall"]
    end

    @tag score: :low
    test "not shows first time submit message when score is already existing", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      refute has_element?(show_live, "#skills-form")
      refute has_element?(show_live, "#help-first-skill-submit-in-overall")
    end

    @tag score: nil
    test "shows job searching message when first submit in overall", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      # job_searching: false に設定
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)
      |> UserJobProfiles.update_user_job_profile(%{job_searching: false})

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      {path, flash} = assert_redirect(show_live)
      assert path == ~p"/graphs/#{skill_panel}?class=1"
      assert flash["first_submit_in_overall"]
      assert flash["first_submit_in_skill_panel"]
    end

    @tag score: nil
    test "shows job searching message when first submit in skill panel", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      # job_searching: false に設定
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)
      |> UserJobProfiles.update_user_job_profile(%{job_searching: false})

      insert_user_skill_panel(user, :low)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      assert has_element?(show_live, "#job_searching_message")
    end

    @tag score: :low
    test "not shows job searching message when job_searching is already true", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      # job_searching: true に設定
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)
      |> UserJobProfiles.update_user_job_profile(%{job_searching: true})

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      refute has_element?(show_live, "#skills-form")
      refute has_element?(show_live, "#job_searching_message")
    end

    @tag score: :low
    test "not shows job searching message when score is already existing", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      # job_searching: false に設定
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)
      |> UserJobProfiles.update_user_job_profile(%{job_searching: false})

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      assert_patched(show_live, ~p"/panels/#{skill_panel}/edit?class=1")
      refute has_element?(show_live, "#skills-form")
      refute has_element?(show_live, "job_searching_message")
    end

    @tag score: :low
    test "shows help message for entering skills on the button side", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#btn-help-enter-skills-button")
      |> render_click()

      assert has_element?(show_live, "#btn-help-enter-skills-button-good")
    end

    @tag score: :low
    test "shows help message for entering skills on the modal", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)
      assert has_element?(show_live, "#skills-form")

      show_live
      |> element("#btn-help-enter-skills-modal")
      |> render_click()

      assert has_element?(show_live, "#btn-help-enter-skills-modal-good")
    end
  end

  describe "Errors" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows 404 if skill_panel_id is invalid ULID", %{conn: conn} do
      assert_raise Ecto.Query.CastError, fn ->
        live(conn, ~p"/panels/abcd")
      end
    end

    test "shows 404 if skill_panel not exists", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{Ecto.ULID.generate()}")
      end
    end

    test "shows 404 if skill_panel not exists, case related user", %{conn: conn, user: user} do
      user_2 = insert(:user) |> with_user_profile()
      team = insert(:team)
      insert(:team_member_users, user: user, team: team)
      insert(:team_member_users, user: user_2, team: team)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{Ecto.ULID.generate()}/#{user_2.name}")
      end
    end

    test "shows 404 if skill_panel not exists, case anonymous user", %{conn: conn} do
      user_2 = insert(:user) |> with_user_profile()
      encrypted_name = BrightWeb.DisplayUserHelper.encrypt_user_name(user_2)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{Ecto.ULID.generate()}/anon/#{encrypted_name}")
      end
    end

    test "shows 404 if class not existing", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{skill_panel}?class=2")
      end
    end

    test "shows 404 if class in not in [1, 2 3]", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{skill_panel}?class=abc")
      end
    end
  end

  # アクセス制御など
  describe "Security" do
    setup [:register_and_log_in_user]

    test "別のユーザーのスキルスコアが表示されないこと", %{conn: conn, user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

      dummy_user = insert(:user)
      insert(:init_skill_class_score, user: dummy_user, skill_class: skill_class)
      insert(:skill_score, user: dummy_user, skill: skill, score: :high)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute has_element?(show_live, ".score-mark-high")

      assert has_element?(show_live, ".score-mark-low")
    end
  end
end
