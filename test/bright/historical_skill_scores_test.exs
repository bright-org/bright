defmodule Bright.HistoricalSkillScoresTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.HistoricalSkillScores

  @current_tl ~D[2023-10-01]
  @back_tl_1 ~D[2023-07-01]

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
end
