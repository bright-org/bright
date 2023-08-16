defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  defp setup_skills(%{user: user, score: score}) do
    skill_panel = insert(:skill_panel)
    skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

    skill_unit =
      insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

    [%{skills: [skill_1, skill_2, skill_3]}] = insert_skill_categories_and_skills(skill_unit, [3])

    if score do
      skill_score = insert(:skill_score, user: user, skill_class: skill_class)
      insert(:skill_score_item, skill_score: skill_score, skill: skill_1, score: score)
      insert(:skill_score_item, skill_score: skill_score, skill: skill_2)
      insert(:skill_score_item, skill_score: skill_score, skill: skill_3)
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

    setup do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    test "shows content", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}/skills")

      assert html =~ "スキルパネル"

      assert show_live
             |> element("#class_tab_1", skill_class.name)
             |> has_element?()
    end

    test "shows skills table", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      [skill_unit_1, skill_unit_2] =
        insert_list(2, :skill_unit,
          skill_class_units: [
            %{skill_class_id: skill_class.id, position: 1}
          ]
        )

      skill_unit_dummy = insert(:skill_unit, name: "紐づいていないダミー")

      skill_categories = insert_skill_categories_and_skills(skill_unit_1, [1, 1, 1])
      insert_skill_categories_and_skills(skill_unit_2, [1, 1, 2])
      insert_skill_categories_and_skills(skill_unit_dummy, [1])

      {:ok, show_live, html} = live(conn, ~p"/panels/#{skill_panel}/skills")

      assert html =~ "スキルパネル"

      # 知識エリアの表示確認
      assert show_live |> element(~s{td[rowspan="3"]}, skill_unit_1.name) |> has_element?()
      assert show_live |> element(~s{td[rowspan="4"]}, skill_unit_2.name) |> has_element?()
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
      skill_panel: skill_panel
    } do
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=2")

      assert show_live
             |> element("#class_tab_1", skill_class_2.name)
             |> has_element?()
    end
  end

  describe "Show skill score item" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: :low
    test "shows mark when score: low", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element(".score-mark-low")
             |> has_element?()
    end

    @tag score: :middle
    test "shows mark when score: middle", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element(".score-mark-middle")
             |> has_element?()
    end

    @tag score: :high
    test "shows mark when score: high", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element(".score-mark-high")
             |> has_element?()
    end
  end

  describe "Input skill score item score" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: :low
    test "update scores", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # skill_1
      # lowからlowのキャンセル操作相当
      show_live
      |> element(~s{#skill-score-item-1 div[phx-click="input"]})
      |> render_click()

      show_live
      |> element(~s{label[phx-value-score="low"]})
      |> render_click()

      # skill_2
      show_live
      |> element(~s{#skill-score-item-2 div[phx-click="input"]})
      |> render_click()

      show_live
      |> element(~s{label[phx-value-score="middle"]})
      |> render_click()

      # skill_3
      show_live
      |> element(~s{#skill-score-item-3 div[phx-click="input"]})
      |> render_click()

      show_live
      |> element(~s{label[phx-value-score="high"]})
      |> render_click()

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="update"]})
      |> render_click()

      # 永続化確認のための再描画
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element("#skill-score-item-1 .score-mark-low")
             |> has_element?()

      assert show_live
             |> element("#skill-score-item-2 .score-mark-middle")
             |> has_element?()

      assert show_live
             |> element("#skill-score-item-3 .score-mark-high")
             |> has_element?()
    end

    @tag score: nil
    test "edits by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # 一番上のスキルを入力モードとする
      show_live
      |> element("#skill-score-item-1 .score-mark-low")
      |> render_click()

      # 1を押してスコアを設定する。以下、2, 3と続く
      show_live
      |> element("#skill-score-item-1")
      |> render_keydown(%{"key" => "1"})

      assert show_live
             |> element("#skill-score-item-1 .score-mark-high")
             |> has_element?()

      show_live
      |> element("#skill-score-item-2")
      |> render_keydown(%{"key" => "2"})

      assert show_live
             |> element("#skill-score-item-2 .score-mark-middle")
             |> has_element?()

      show_live
      |> element("#skill-score-item-3")
      |> render_keydown(%{"key" => "3"})

      assert show_live
             |> element("#skill-score-item-3 .score-mark-low")
             |> has_element?()

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="update"]})
      |> render_click()

      # 永続化確認のための再描画
      {:ok, _show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element("#skill-score-item-1 .score-mark-high")
             |> has_element?()

      assert show_live
             |> element("#skill-score-item-2 .score-mark-middle")
             |> has_element?()

      assert show_live
             |> element("#skill-score-item-3 .score-mark-low")
             |> has_element?()
    end

    @tag score: nil
    test "move by key input", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      # 編集モード IN
      show_live
      |> element(~s{button[phx-click="edit"]})
      |> render_click()

      # 一番上のスキルを入力モードとする
      show_live
      |> element("#skill-score-item-1 .score-mark-low")
      |> render_click()

      # ↓、Enter、↑による移動
      show_live
      |> element("#skill-score-item-1")
      |> render_keydown(%{"key" => "ArrowDown"})

      assert show_live
             |> element("#skill-score-item-2 input")
             |> has_element?()

      refute show_live
             |> element("#skill-score-item-1 input")
             |> has_element?()

      show_live
      |> element("#skill-score-item-2")
      |> render_keydown(%{"key" => "Enter"})

      assert show_live
             |> element("#skill-score-item-3 input")
             |> has_element?()

      refute show_live
             |> element("#skill-score-item-2 input")
             |> has_element?()

      show_live
      |> element("#skill-score-item-3")
      |> render_keydown(%{"key" => "ArrowUp"})

      assert show_live
             |> element("#skill-score-item-2 input")
             |> has_element?()

      refute show_live
             |> element("#skill-score-item-3 input")
             |> has_element?()

      # 編集モード OUT
      show_live
      |> element(~s{button[phx-click="update"]})
      |> render_click()

      # 編集モードから抜けると、入力モードも解除される
      refute show_live
             |> element("#skill-score-item-2 input")
             |> has_element?()
    end
  end

  describe "Shows skill score percentages" do
    setup [:register_and_log_in_user, :setup_skills]

    @tag score: nil
    test "shows updated value", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

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
      |> element("#skill-score-item-1 .score-mark-low")
      |> render_click()

      show_live
      |> element("#skill-score-item-1")
      |> render_keydown(%{"key" => "1"})

      assert show_live
             |> element(".score-high-percentage", "33％")
             |> has_element?()

      show_live
      |> element("#skill-score-item-2")
      |> render_keydown(%{"key" => "1"})

      assert show_live
             |> element(".score-high-percentage", "66％")
             |> has_element?()

      show_live
      |> element("#skill-score-item-3")
      |> render_keydown(%{"key" => "2"})

      assert show_live
             |> element(".score-middle-percentage", "33％")
             |> has_element?()

      show_live
      |> element(~s{button[phx-click="update"]})
      |> render_click()

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

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
      |> element("#skill-score-item-1 .score-mark-high")
      |> render_click()

      show_live
      |> element("#skill-score-item-1")
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element("#skill-score-item-2")
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element("#skill-score-item-3")
      |> render_keydown(%{"key" => "3"})

      show_live
      |> element(~s{button[phx-click="update"]})
      |> render_click()

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

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
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/evidences")

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

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      show_live
      |> element("#skill-1 .link-evidence")
      |> render_click()

      assert show_live
             |> render() =~ skill_evidence_post.content

      assert show_live
             |> form("#skill_evidence_post-form", skill_evidence_post: %{content: ""})
             |> render_submit() =~ "can&#39;t be blank"

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
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      show_live
      |> element("#skill-1 .link-reference")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/reference")

      assert render(show_live) =~ skill_1.name

      assert show_live
             |> element(~s(a[href="#{skill_reference.url}"][target="_blank"]))
             |> has_element?()
    end

    @tag score: nil
    test "教材がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      refute show_live
             |> element("#skill-1 .link-reference")
             |> has_element?()
    end

    @tag score: nil
    test "教材のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_reference, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

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
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      show_live
      |> element("#skill-1 .link-exam")
      |> render_click()

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill_1}/exam")

      assert render(show_live) =~ skill_1.name

      assert show_live
             |> element(~s(a[href="#{skill_exam.url}"][target="_blank"]))
             |> has_element?()
    end

    @tag score: nil
    test "試験がないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      refute show_live
             |> element("#skill-1 .link-exam")
             |> has_element?()
    end

    @tag score: nil
    test "試験のURLがないスキルのリンクが表示されないこと", %{conn: conn, skill_panel: skill_panel, skill_1: skill_1} do
      insert(:skill_exam, skill: skill_1, url: nil)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      refute show_live
             |> element("#skill-1 .link-exam")
             |> has_element?()
    end
  end

  # アクセス制御など
  describe "Security" do
    setup [:register_and_log_in_user]

    test "別のユーザーのスキルスコアが表示されないこと", %{conn: conn} do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

      dummy_user = insert(:user)

      insert(:skill_score_item,
        skill_score: build(:skill_score, user: dummy_user, skill_class: skill_class),
        skill: skill,
        score: :high
      )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

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
