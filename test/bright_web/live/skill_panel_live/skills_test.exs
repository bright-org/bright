defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  defp setup_skills(%{user: user, score: score}) do
    skill_panel = insert(:skill_panel)
    insert(:user_skill_panel, user: user, skill_panel: skill_panel)
    skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

    skill_unit =
      insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

    [%{skills: [skill_1, skill_2, skill_3]}] = insert_skill_categories_and_skills(skill_unit, [3])

    if score do
      insert(:init_skill_class_score, user: user, skill_class: skill_class)
      _skill_unit_score = insert(:skill_unit_score, user: user, skill_unit: skill_unit)
      insert(:skill_score, user: user, skill: skill_1, score: score)
      insert(:skill_score, user: user, skill: skill_2)
      insert(:skill_score, user: user, skill: skill_3)
    end

    %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill_1: skill_1,
      skill_2: skill_2,
      skill_3: skill_3
    }
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

    test "show content with no skill panel message", %{conn: conn} do
      {:ok, _show_live, html} = live(conn, ~p"/panels")

      assert html =~ "スキルパネルがありません"
    end
  end

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

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # skill_1
      # lowからlowのキャンセル操作相当
      show_live
      |> element(~s{#skill-1 label[phx-value-score="low"]})
      |> render_click()

      show_live
      |> element(~s{#skill-2 label[phx-value-score="middle"]})
      |> render_click()

      show_live
      |> element(~s{#skill-3 label[phx-value-score="high"]})
      |> render_click()

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="submit"]})
      |> render_click()

      # 編集モードが解除されているかの確認
      assert show_live |> has_element?("#skill-1 .score-mark-low")
      assert show_live |> has_element?("#skill-2 .score-mark-middle")
      assert show_live |> has_element?("#skill-3 .score-mark-high")

      # 永続化確認のための再描画
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live |> has_element?("#skill-1 .score-mark-low")
      assert show_live |> has_element?("#skill-2 .score-mark-middle")
      assert show_live |> has_element?("#skill-3 .score-mark-high")
    end

    @tag score: nil
    test "edits by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # 1を押してスコアを設定する。以下、2, 3と続く
      # 最終行は押してもそのままフォーカスした状態を継続する
      show_live
      |> element(~s{#skill-1 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      refute show_live |> has_element?(~s{#skill-1 [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-2 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "2"})

      refute show_live |> has_element?(~s{#skill-2 [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-3 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      assert show_live |> has_element?(~s{#skill-3 [phx-window-keydown="shortcut"]})

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="submit"]})
      |> render_click()

      # 永続化確認のための再描画
      {:ok, _show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live |> has_element?("#skill-1 .score-mark-high")
      assert show_live |> has_element?("#skill-2 .score-mark-middle")
      assert show_live |> has_element?("#skill-3 .score-mark-low")
    end

    @tag score: nil
    test "move by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # ↓、Enter、↑による移動
      # 最初と最終行は押してもそのままフォーカスした状態を継続する
      show_live
      |> element(~s{#skill-1 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowUp"})

      show_live
      |> element(~s{#skill-1 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowDown"})

      refute show_live |> has_element?(~s{#skill-1 [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-2 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "Enter"})

      refute show_live |> has_element?(~s{#skill-2 [phx-window-keydown="shortcut"]})

      show_live
      |> element(~s{#skill-3 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowDown"})

      show_live
      |> element(~s{#skill-3 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "ArrowUp"})

      refute show_live |> has_element?(~s{#skill-3 [phx-window-keydown="shortcut"]})

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="submit"]})
      |> render_click()
    end
  end

  describe "Shows skill score percentages" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows updated value", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # 初期表示
      assert show_live
             |> element(".score-high-percentage", "0％")
             |> has_element?()

      assert show_live
             |> element(".score-middle-percentage", "0％")
             |> has_element?()

      # 各スキルスコア入力と、習得率表示更新
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      show_live
      |> element(~s{#skill-1 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      assert show_live
             |> element(".score-high-percentage", "33％")
             |> has_element?()

      show_live
      |> element(~s{#skill-2 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "1"})

      assert show_live
             |> element(".score-high-percentage", "66％")
             |> has_element?()

      show_live
      |> element(~s{#skill-3 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "2"})

      assert show_live
             |> element(".score-middle-percentage", "33％")
             |> has_element?()

      show_live
      |> element(~s{button[phx-click="submit"]})
      |> render_click()

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live
             |> element(".score-high-percentage", "66％")
             |> has_element?()

      assert show_live
             |> element(".score-middle-percentage", "33％")
             |> has_element?()

      # 各スキルスコアの削除（lowにする操作）と、習得率表示更新
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      show_live
      |> element(~s{#skill-1 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-2 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{#skill-3 [phx-window-keydown="shortcut"]})
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{button[phx-click="submit"]})
      |> render_click()

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      assert show_live
             |> element(".score-high-percentage", "0％")
             |> has_element?()

      assert show_live
             |> element(".score-middle-percentage", "0％")
             |> has_element?()
    end
  end

  # エビデンス登録
  describe "Skill evidence area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/evidences?class=1")

      assert show_live
             |> render() =~ skill_1.name
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

      assert show_live
             |> render() =~ skill_evidence_post.content

      assert show_live
             |> form("#skill_evidence_post-form", skill_evidence_post: %{content: ""})
             |> render_submit() =~ "入力してください"

      show_live
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input 1"})
      |> render_submit()

      assert show_live
             |> has_element?("#skill_evidence_posts", "input 1")

      refute show_live
             |> has_element?("#skill_evidence_post-form", "input 1")

      show_live
      |> element(~s([phx-click="delete"][phx-value-id="#{skill_evidence_post.id}"]))
      |> render_click()

      refute show_live
             |> has_element?("#skill_evidence_posts", "some content")
    end
  end

  # 教材
  describe "Skill reference area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      skill_reference = insert(:skill_reference, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-reference")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/reference?class=1")

      assert render(show_live) =~ skill_1.name

      assert show_live
             |> has_element?(~s(iframe#iframe-skill-reference[src="#{skill_reference.url}"]))
    end

    @tag score: nil
    test "教材がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute show_live
             |> element("#skill-1 .link-reference")
             |> has_element?()
    end

    @tag score: nil
    test "教材のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_reference, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute show_live
             |> element("#skill-1 .link-reference")
             |> has_element?()
    end
  end

  # 試験
  describe "Skill exam area" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows modal", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      skill_exam = insert(:skill_exam, skill: skill_1)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      show_live
      |> element("#skill-1 .link-exam")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/exam?class=1")

      assert render(show_live) =~ skill_1.name

      assert show_live
             |> has_element?(~s(iframe#iframe-skill-exam[src="#{skill_exam.url}"]))
    end

    @tag score: nil
    test "試験がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute show_live
             |> element("#skill-1 .link-exam")
             |> has_element?()
    end

    @tag score: nil
    test "試験のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_exam, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      refute show_live
             |> element("#skill-1 .link-exam")
             |> has_element?()
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

      refute show_live
             |> element(".score-mark-high")
             |> has_element?()

      assert show_live
             |> element(".score-mark-low")
             |> has_element?()
    end

    # # TODO: 画面にアクセスできるようになったらテストを実装する。
    # test "別のユーザーで編集モードに入れないこと" do
    # end
  end
end
