defmodule Bright.HistoricalSkillScoresTest do
  use Bright.DataCase

  alias Bright.HistoricalSkillScores

  @current_tl ~D[2023-10-01]
  @back_tl_1 ~D[2023-07-01]
  @back_tl_2 ~D[2023-04-01]
  @back_tl_3 ~D[2023-01-01]
  @back_tl_4 ~D[2022-10-01]
  @back_tl_5 ~D[2022-07-01]

  describe "historical_skill_scores" do
    setup do
      user = insert(:user)

      historical_skill_class =
        insert(:historical_skill_class,
          skill_panel: build(:historical_skill_panel),
          class: 1,
          locked_date: @back_tl_1
        )

      historical_skill_unit = insert(:historical_skill_unit)

      insert(:historical_skill_class_unit,
        historical_skill_class_id: historical_skill_class.id,
        historical_skill_unit_id: historical_skill_unit.id
      )

      historical_skill_category =
        insert(:historical_skill_category,
          historical_skill_unit: historical_skill_unit,
          position: 1
        )

      historical_skill =
        insert(:historical_skill,
          historical_skill_category: historical_skill_category,
          position: 1
        )

      %{
        user: user,
        historical_skill_class: historical_skill_class,
        historical_skill_unit: historical_skill_unit,
        historical_skill_category: historical_skill_category,
        historical_skill: historical_skill
      }
    end

    test "list_historical_skill_scores returns historical_skill_scores", %{
      user: user,
      historical_skill: historical_skill
    } do
      historical_skill_score =
        insert(:historical_skill_score, user: user, historical_skill: historical_skill)

      assert HistoricalSkillScores.list_historical_skill_scores()
             |> Enum.map(& &1.id) == [historical_skill_score.id]
    end

    test "list_historical_skill_scores_from_historical_skill_class_score", %{
      user: user,
      historical_skill_class: historical_skill_class,
      historical_skill: historical_skill
    } do
      # ダミーとして別ユーザー(user_2)データを作成
      user_2 = insert(:user)

      insert(:historical_skill_class_score,
        user: user_2,
        historical_skill_class: historical_skill_class,
        locked_date: @current_tl
      )

      insert(:historical_skill_score, user: user_2, historical_skill: historical_skill)

      historical_skill_class_score =
        insert(:historical_skill_class_score,
          user: user,
          historical_skill_class: historical_skill_class,
          locked_date: @current_tl
        )

      historical_skill_score =
        insert(:historical_skill_score, user: user, historical_skill: historical_skill)

      ret =
        HistoricalSkillScores.list_historical_skill_scores_from_historical_skill_class_score(
          historical_skill_class_score
        )

      assert ret |> Enum.map(& &1.id) == [historical_skill_score.id]
    end

    test "list_user_historical_skill_scores_from_historical_skill_ids", %{
      user: user,
      historical_skill_category: historical_skill_category,
      historical_skill: historical_skill
    } do
      # ダミーとして別ユーザー(user_2)データを作成
      user_2 = insert(:user)
      insert(:historical_skill_score, user: user_2, historical_skill: historical_skill)
      # ダミーとして別スキルデータを作成
      historical_skill_2 =
        insert(:historical_skill,
          historical_skill_category: historical_skill_category,
          position: 2
        )

      insert(:historical_skill_score, user: user, historical_skill: historical_skill_2)

      historical_skill_score =
        insert(:historical_skill_score, user: user, historical_skill: historical_skill)

      ret =
        HistoricalSkillScores.list_user_historical_skill_scores_from_historical_skill_ids(
          [
            historical_skill.id
          ],
          user.id
        )

      assert ret |> Enum.map(& &1.id) == [historical_skill_score.id]
    end
  end

  describe "get_historical_skill_gem" do
    setup do
      user = insert(:user)
      skill_panel = insert(:historical_skill_panel)

      historical_skill_class =
        insert(:historical_skill_class,
          skill_panel: skill_panel,
          class: 1,
          locked_date: @back_tl_2
        )

      historical_skill_unit_1 = insert(:historical_skill_unit, locked_date: @back_tl_2)
      historical_skill_unit_2 = insert(:historical_skill_unit, locked_date: @back_tl_2)
      historical_skill_unit_3 = insert(:historical_skill_unit, locked_date: @back_tl_2)

      [
        {historical_skill_unit_1, 10},
        {historical_skill_unit_2, 20},
        {historical_skill_unit_3, 30}
      ]
      |> Enum.each(fn {historical_skill_unit, position} ->
        insert(:historical_skill_class_unit,
          historical_skill_class_id: historical_skill_class.id,
          historical_skill_unit_id: historical_skill_unit.id,
          position: position
        )
      end)

      [
        {historical_skill_unit_1, 0.1},
        {historical_skill_unit_2, 0.2},
        {historical_skill_unit_3, 0.3}
      ]
      |> Enum.each(fn {historical_skill_unit, percentage} ->
        insert(:historical_skill_unit_score,
          user: user,
          historical_skill_unit: historical_skill_unit,
          percentage: percentage,
          locked_date: @back_tl_1
        )
      end)

      gem_data = [
        %{
          name: historical_skill_unit_1.name,
          trace_id: historical_skill_unit_1.trace_id,
          position: 10,
          percentage: 0.1
        },
        %{
          name: historical_skill_unit_2.name,
          trace_id: historical_skill_unit_2.trace_id,
          position: 20,
          percentage: 0.2
        },
        %{
          name: historical_skill_unit_3.name,
          trace_id: historical_skill_unit_3.trace_id,
          position: 30,
          percentage: 0.3
        }
      ]

      %{
        user: user,
        skill_panel: skill_panel,
        historical_skill_units: [
          historical_skill_unit_1,
          historical_skill_unit_2,
          historical_skill_unit_3
        ],
        gem_data: gem_data
      }
    end

    test "gets correct gem data given args", %{
      user: user,
      skill_panel: skill_panel,
      gem_data: gem_data
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_2)
      assert ret == gem_data
    end

    test "gets zero scores, case incorrect user", %{
      user: _user,
      skill_panel: skill_panel,
      gem_data: gem_data
    } do
      user = insert(:user)
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_2)
      assert ret == Enum.map(gem_data, &Map.put(&1, :percentage, 0.0))
    end

    test "gets empty, case incorrect skill_panel", %{
      user: user,
      skill_panel: _skill_panel
    } do
      skill_panel = insert(:historical_skill_panel)
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_2)
      assert ret == []
    end

    test "gets empty, case incorrect skill_classes.class", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 2, @back_tl_2)
      assert ret == []
    end

    test "gets empty, case incorrect locked_date", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_1)
      assert ret == []
    end

    test "returns same skill_panels historical_skill_class_units.position", %{
      user: user,
      skill_panel: skill_panel,
      historical_skill_units: historical_skill_units,
      gem_data: gem_data
    } do
      # スキルユニットを共有している状態で、指定したskill_panelでのpositionを取得できることの確認
      # データ準備として別のスキルパネルを作っている。そちらでは共有のskill_units.position: 1としている
      skill_panel_another = insert(:historical_skill_panel)

      historical_skill_class_another =
        insert(:historical_skill_class,
          skill_panel: skill_panel_another,
          class: 1,
          locked_date: @back_tl_2
        )

      historical_skill_units
      |> Enum.each(fn historical_skill_unit ->
        insert(:historical_skill_class_unit,
          historical_skill_class_id: historical_skill_class_another.id,
          historical_skill_unit_id: historical_skill_unit.id,
          position: 1
        )
      end)

      historical_skill_units
      |> Enum.each(fn historical_skill_unit ->
        insert(:historical_skill_unit_score,
          user: user,
          historical_skill_unit: historical_skill_unit,
          percentage: 0.1,
          locked_date: @back_tl_1
        )
      end)

      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_2)
      assert ret == gem_data
    end
  end

  describe "list_historical_skill_class_score_percentages" do
    setup do
      user = insert(:user)
      skill_panel = insert(:historical_skill_panel)

      [
        {@back_tl_1, 0.5},
        {@back_tl_2, 0.4},
        {@back_tl_3, 0.3},
        {@back_tl_4, 0.2},
        {@back_tl_5, 0.1}
      ]
      |> Enum.each(fn {locked_date, percentage} ->
        historical_skill_class =
          insert(:historical_skill_class,
            skill_panel: skill_panel,
            class: 1,
            locked_date: locked_date
          )

        insert(:historical_skill_class_score,
          user: user,
          historical_skill_class: historical_skill_class,
          locked_date: Timex.shift(locked_date, months: 3),
          percentage: percentage
        )
      end)

      %{user: user, skill_panel: skill_panel}
    end

    test "returns percentages as given dates", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          1,
          user.id,
          @back_tl_1,
          @back_tl_1
        )

      assert ret == [
               {Timex.shift(@back_tl_1, months: 3), 0.5}
             ]

      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          1,
          user.id,
          @back_tl_5,
          @back_tl_1
        )

      assert ret == [
               {Timex.shift(@back_tl_5, months: 3), 0.1},
               {Timex.shift(@back_tl_4, months: 3), 0.2},
               {Timex.shift(@back_tl_3, months: 3), 0.3},
               {Timex.shift(@back_tl_2, months: 3), 0.4},
               {Timex.shift(@back_tl_1, months: 3), 0.5}
             ]
    end

    test "returns empty, case incorrect user", %{
      user: _user,
      skill_panel: skill_panel
    } do
      user = insert(:user)

      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          1,
          user.id,
          @back_tl_1,
          @back_tl_1
        )

      assert ret == []
    end

    test "returns empty, case incorrect skill_panel", %{
      user: user,
      skill_panel: _skill_panel
    } do
      skill_panel = insert(:historical_skill_panel)

      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          1,
          user.id,
          @back_tl_1,
          @back_tl_1
        )

      assert ret == []
    end

    test "returns empty, case incorrect skill_classes.class", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          2,
          user.id,
          @back_tl_1,
          @back_tl_1
        )

      assert ret == []
    end

    test "returns empty, case incorrect locked_date", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret =
        HistoricalSkillScores.list_historical_skill_class_score_percentages(
          skill_panel.id,
          1,
          user.id,
          @back_tl_1,
          @back_tl_2
        )

      assert ret == []
    end
  end

  describe "list_historical_skill_unit_scores_by_user_skill_units" do
    test "returns historical_skill_unit_scores" do
      [user_1, user_2] = insert_pair(:user)

      [skill_unit_1, skill_unit_2] = skill_units = insert_pair(:skill_unit)
      dummy_skill_unit = insert(:skill_unit)

      historical_1 = insert(:historical_skill_unit, trace_id: skill_unit_1.trace_id)
      historical_2 = insert(:historical_skill_unit, trace_id: skill_unit_2.trace_id)

      date = ~D[2024-07-01]

      historical_score_1 =
        insert(:historical_skill_unit_score,
          user: user_1,
          historical_skill_unit: historical_1,
          locked_date: date
        )

      historical_score_2 =
        insert(:historical_skill_unit_score,
          user: user_1,
          historical_skill_unit: historical_2,
          locked_date: date
        )

      # # 指定の条件で取れること
      [%{id: id_1}, %{id: id_2}] =
        HistoricalSkillScores.list_historical_skill_unit_scores_by_user_skill_units(
          user_1,
          skill_units,
          date
        )

      assert Enum.sort([id_1, id_2]) == Enum.sort([historical_score_1.id, historical_score_2.id])

      # 別ユーザー指定で取れないこと
      assert [nil, nil] ==
               HistoricalSkillScores.list_historical_skill_unit_scores_by_user_skill_units(
                 user_2,
                 skill_units,
                 date
               )

      # 別スキルユニット指定で取れないこと
      assert [nil] ==
               HistoricalSkillScores.list_historical_skill_unit_scores_by_user_skill_units(
                 user_1,
                 [dummy_skill_unit],
                 date
               )

      # 別日指定で取れないこと
      assert [nil, nil] ==
               HistoricalSkillScores.list_historical_skill_unit_scores_by_user_skill_units(
                 user_1,
                 skill_units,
                 ~D[2024-08-01]
               )
    end
  end
end
