defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.UserJobProfiles

  defp setup_skills(%{user: user, score: score}) do
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

    assert has_element?(show_live, "#skills-form")
  end

  # 共通処理: 入力完了
  defp submit_form(show_live) do
    show_live
    |> element(~s{button[phx-click="submit"]})
    |> render_click()

    refute has_element?(show_live, "#skills-form")
  end

  describe "Show" do
    setup [:register_and_log_in_user]

    setup %{user: user} do
      skill_panel = insert(:skill_panel)
      insert(:user_skill_panel, user: user, skill_panel: skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows content", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}")

      assert html =~ "スキルパネル"

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
    end

    test "shows content without parameters", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels")

      assert html =~ skill_panel.name

      assert show_live
             |> has_element?("#class_tab_1", skill_class.name)
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
      user: user,
      skill_panel: skill_panel
    } do
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)
      insert(:init_skill_class_score, user: user, skill_class: skill_class_2)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=2")

      assert show_live
             |> has_element?("#class_tab_2", skill_class_2.name)
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

  describe "Input skill score item score" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: :low
    test "update scores", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

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

      # 永続化確認のための再描画
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, "#skill-1 .score-mark-low")
      assert has_element?(show_live, "#skill-2 .score-mark-middle")
      assert has_element?(show_live, "#skill-3 .score-mark-high")
    end

    @tag score: nil
    test "edits by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

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

      # 永続化確認のための再描画
      {:ok, _show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, "#skill-1 .score-mark-high")
      assert has_element?(show_live, "#skill-2 .score-mark-middle")
      assert has_element?(show_live, "#skill-3 .score-mark-low")
    end

    @tag score: nil
    test "move by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

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

      assert has_element?(show_live, "#doughnut_area_in_skills_form", "見習い")
      assert has_element?(show_live, "#doughnut_area_in_skills_form .score-high-percentage", "0％")

      assert has_element?(
               show_live,
               "#doughnut_area_in_skills_form .score-middle-percentage",
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

      assert has_element?(show_live, "#doughnut_area_in_skills_form", "ベテラン")

      assert has_element?(
               show_live,
               "#doughnut_area_in_skills_form .score-high-percentage",
               "66％"
             )

      assert has_element?(
               show_live,
               "#doughnut_area_in_skills_form .score-middle-percentage",
               "33％"
             )

      submit_form(show_live)

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert has_element?(show_live, ".score-high-percentage", "66％")
      assert has_element?(show_live, ".score-middle-percentage", "33％")

      # 各スキルスコアの削除（lowにする操作）と、習得率表示更新
      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-2-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-3-form [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      assert has_element?(show_live, "#doughnut_area_in_skills_form", "見習い")
      assert has_element?(show_live, "#doughnut_area_in_skills_form .score-high-percentage", "0％")

      assert has_element?(
               show_live,
               "#doughnut_area_in_skills_form .score-middle-percentage",
               "0％"
             )

      submit_form(show_live)

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
             |> element("h4")
             |> render() =~ skill_panel_2.name

      # 自分に戻す
      {:ok, show_live, _html} =
        show_live
        |> element("button", "自分に戻す")
        |> render_click()
        |> follow_redirect(conn)

      assert show_live
             |> element("h4")
             |> render() =~ skill_panel.name
    end
  end

  # エビデンス登録
  describe "Skill evidence area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal case: skill_score NOT existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/evidences?class=1")
      assert render(show_live) =~ skill_1.name
    end

    @tag score: :low
    test "shows modal case: skill_score existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill_1
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/evidences?class=1")
      assert render(show_live) =~ skill_1.name
    end

    @tag score: nil
    test "creates and deletes post", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_1: skill,
      user: user
    } do
      # ここからのエビデンス登録系テストは別ファイルにする検討
      # 別LiveViewからコンポーネントを使う可能性もある

      skill_evidence = insert(:skill_evidence, user: user, skill: skill, progress: :wip)

      skill_evidence_post =
        insert(:skill_evidence_post,
          user: user,
          skill_evidence: skill_evidence,
          content: "some content"
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert render(show_live) =~ skill_evidence_post.content

      assert show_live
             |> form("#skill_evidence_post-form", skill_evidence_post: %{content: ""})
             |> render_submit() =~ "入力してください"

      show_live
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input 1"})
      |> render_submit()

      assert has_element?(show_live, "#skill_evidence_posts", "input 1")
      refute has_element?(show_live, "#skill_evidence_post-form", "input 1")

      show_live
      |> element(~s([phx-click="delete"][phx-value-id="#{skill_evidence_post.id}"]))
      |> render_click()

      refute has_element?(show_live, "#skill_evidence_posts", "some content")
    end
  end

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
    alias BrightWeb.SkillPanelLive.TimelineHelper
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

  describe "Messages" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows first skills edit message", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      assert has_element?(show_live, "#first_skills_edit_message")

      # 入力後に表示されないことの確認
      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="middle"]})
      |> render_click()

      submit_form(show_live)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      refute has_element?(show_live, "#first_skills_edit_message")
    end

    @tag score: nil
    test "shows first time submit message", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      assert has_element?(show_live, "#first_submit_in_overall_message")
    end

    @tag score: :low
    test "not shows first time submit message when score is already existing", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      refute has_element?(show_live, "#first_submit_in_overall_message")
    end

    @tag score: :low
    test "shows next skill class opened message", %{conn: conn, skill_panel: skill_panel} do
      insert(:skill_class, skill_panel: skill_panel, class: 2)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="high"]})
      |> render_click()

      show_live
      |> element(~s{#skill-2-form label[phx-value-score="high"]})
      |> render_click()

      submit_form(show_live)
      assert has_element?(show_live, "#next_skill_class_opened_message")
    end

    @tag score: :low
    test "not shows next skill class opened message when not opened", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      insert(:skill_class, skill_panel: skill_panel, class: 2)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="middle"]})
      |> render_click()

      submit_form(show_live)
      refute has_element?(show_live, "#next_skill_class_opened_message")
    end

    @tag score: nil
    test "shows job searching message", %{conn: conn, user: user, skill_panel: skill_panel} do
      # job_searching: false に設定
      UserJobProfiles.get_user_job_profile_by_user_id!(user.id)
      |> UserJobProfiles.update_user_job_profile(%{job_searching: false})

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      start_edit(show_live)

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
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

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
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

      show_live
      |> element(~s{#skill-1-form label[phx-value-score="low"]})
      |> render_click()

      submit_form(show_live)
      refute has_element?(show_live, "job_searching_message")
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
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/abcd")
      end
    end

    test "shows 404 if skill_panel not exists", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/panels/#{Ecto.ULID.generate()}")
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

    test "shows 404 if class not allowed", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      insert(:skill_class, skill_panel: skill_panel, class: 2)

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

    # # TODO: 画面にアクセスできるようになったらテストを実装する。
    # test "別のユーザーで編集モードに入れないこと" do
    # end
  end
end
