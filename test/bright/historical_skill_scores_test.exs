defmodule Bright.HistoricalSkillScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.HistoricalSkillScores

  @current_tl ~D[2023-10-01]
  @back_tl_1 ~D[2023-07-01]
  @back_tl_2 ~D[2023-04-01]

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
        {historical_skill_unit_1, 1},
        {historical_skill_unit_2, 2},
        {historical_skill_unit_3, 3}
      ] |> Enum.each(fn {historical_skill_unit, position} ->
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
      ] |> Enum.each(fn {historical_skill_unit, percentage} ->
        insert(:historical_skill_unit_score,
          user: user,
          historical_skill_unit: historical_skill_unit,
          percentage: percentage,
          locked_date: @back_tl_1
        )
      end)

      gem_data = [
        %{name: historical_skill_unit_1.name, position: 1, percentage: 0.1},
        %{name: historical_skill_unit_2.name, position: 2, percentage: 0.2},
        %{name: historical_skill_unit_3.name, position: 3, percentage: 0.3}
      ]

      %{user: user, skill_panel: skill_panel, gem_data: gem_data}
    end

    test "gets correct gem data given args", %{
      user: user,
      skill_panel: skill_panel,
      gem_data: gem_data
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_1)
      assert ret == gem_data
    end

    test "gets zero scores, case incorrect user", %{
      user: _user,
      skill_panel: skill_panel,
      gem_data: gem_data
    } do
      user = insert(:user)
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_1)
      assert ret == Enum.map(gem_data, & Map.put(&1, :percentage, 0.0))
    end

    test "gets empty, case incorrect skill_panel", %{
      user: user,
      skill_panel: _skill_panel
    } do
      skill_panel = insert(:historical_skill_panel)
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_1)
      assert ret == []
    end

    test "gets empty, case incorrect skill_classes.class", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 2, @back_tl_1)
      assert ret == []
    end

    test "gets empty, case incorrect locked_date", %{
      user: user,
      skill_panel: skill_panel
    } do
      ret = HistoricalSkillScores.get_historical_skill_gem(user.id, skill_panel.id, 1, @back_tl_2)
      assert ret == []
    end
  end
end
