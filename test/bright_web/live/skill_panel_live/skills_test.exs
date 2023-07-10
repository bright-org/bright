defmodule BrightWeb.SkillPanelLive.SkillsTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  # スキルユニットのカテゴリとスキル生成用ヘルパ
  #
  # categories_num_skills:
  #   それぞれのスキルカテゴリに作成するスキル数を格納した配列
  #   [2,1,1] ~ 3つのスキルカテゴリを生成し、最初のスキルカテゴリには2つのスキルを生成
  #
  defp insert_skill_categories_and_skills(skill_unit, categories_num_skills) do
    categories_num_skills
    |> Enum.with_index(1)
    |> Enum.map(fn {num_skills, position_category} ->
      skill_params =
        Enum.map(1..num_skills, fn position_skill ->
          params_for(:skill, position: position_skill)
        end)

      insert(
        :skill_category,
        skill_unit: skill_unit,
        position: position_category,
        skills: skill_params
      )
    end)
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
             |> element("h3", skill_class.name)
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
             |> element("h3", skill_class_2.name)
             |> has_element?()
    end
  end

  describe "Show skill score item" do
    setup [:register_and_log_in_user]

    setup %{score: score, user: user} do
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 1}])

      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

      if score do
        insert(:skill_score_item,
          skill_score: build(:skill_score, user: user, skill_class: skill_class),
          skill: skill,
          score: score
        )
      end

      %{skill_panel: skill_panel, skill_class: skill_class, skill: skill}
    end

    @tag score: nil
    test "shows mark when not registered", %{conn: conn, skill_panel: skill_panel} do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}/skills?class=1")

      assert show_live
             |> element(".score-mark-none")
             |> has_element?()
    end

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
             |> element(".score-mark-none")
             |> has_element?()
    end
  end
end
