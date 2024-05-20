defmodule Bright.SkillScoresTest do
  use Bright.DataCase

  alias Bright.SkillScores
  alias Bright.Notifications

  describe "skill_class_scores" do
    alias Bright.SkillScores.SkillClassScore

    setup do
      user = insert(:user, name: "Hoge")
      skill_panel = insert(:skill_panel, name: "Elixir基本")
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1, name: "零細Web開発")

      %{user: user, skill_panel: skill_panel, skill_class: skill_class}
    end

    test "get_level_judgment_value returns level judgment value" do
      [
        {:normal, 40},
        {:skilled, 60},
        {:master, 100}
      ]
      |> Enum.each(fn {level, expected_value} ->
        assert expected_value == SkillScores.get_level_judgment_value(level)
      end)
    end

    test "list_skill_class_scores/0 returns all skill_class_scores", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)

      assert SkillScores.list_skill_class_scores()
             |> Enum.map(& &1.id) == [skill_class_score.id]
    end

    test "get_skill_class_score!/1 returns the skill_class_score with given id", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      assert skill_class_score.id == SkillScores.get_skill_class_score!(skill_class_score.id).id
    end

    test "create_skill_class_score/2 creates a skill_class_score and skill_scores", %{
      user: user,
      skill_class: skill_class
    } do
      {:ok, multi_result} = SkillScores.create_skill_class_score(skill_class, user.id)
      assert %{skill_class_score_init: skill_class_score} = multi_result

      assert skill_class_score.level == :beginner
      assert skill_class_score.percentage == 0.0
    end

    test "create_skill_class_score/2 case duplicated skill_scores", %{
      user: user,
      skill_class: skill_class
    } do
      # 他skill_classで作成済み（共有している）ケースの確認
      # 既に作成済みの場合はskill_unit_scores/skill_scoresは作成対象外になる。

      # 以下のケースでは、
      # - skill_unitを入力済み（skill_class/skill_class2で共有）
      # - skill_unit_2を未入力
      # としている
      skill_class_2 = insert(:skill_class, skill_panel: build(:skill_panel), class: 1)

      skill_unit_1 =
        insert(:skill_unit,
          skill_class_units: [
            %{skill_class_id: skill_class.id, position: 1},
            %{skill_class_id: skill_class_2.id, position: 1}
          ]
        )

      skill_unit_2 =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 2}])

      [%{skills: [skill_1]}] = insert_skill_categories_and_skills(skill_unit_1, [1])
      [%{skills: [_skill_2]}] = insert_skill_categories_and_skills(skill_unit_2, [1])

      # 入力済み扱いのデータ準備
      # - skill_class_2で入力済みの状況作成
      insert(:init_skill_class_score, user: user, skill_class: skill_class_2)
      insert(:skill_score, user: user, skill: skill_1, score: :high)

      {:ok, _} = SkillScores.create_skill_class_score(skill_class, user.id)

      # 既に入力済みのスコアが反映される
      skill_class_score =
        Repo.get_by!(SkillClassScore, %{
          user_id: user.id,
          skill_class_id: skill_class.id
        })

      assert skill_class_score.level == :normal
      assert skill_class_score.percentage == 50.0
    end

    test "update_skill_class_score_stats", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:skill_score, user: user, skill: skill_1, score: :low)
      insert(:skill_score, user: user, skill: skill_2, score: :high)

      {:ok, _} = SkillScores.update_skill_class_score_stats(skill_class_score, skill_class)

      skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
      assert skill_class_score.level == :normal
      assert skill_class_score.percentage == 50.0
    end

    test "update_skill_class_score_stats without items ", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      {:ok, _} = SkillScores.update_skill_class_score_stats(skill_class_score, skill_class)

      skill_class_score = SkillScores.get_skill_class_score!(skill_class_score.id)
      assert skill_class_score.level == :beginner
      assert skill_class_score.percentage == 0.0
    end

    test "update_skill_class_score_stats with notification", %{
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])
      insert(:skill_score, user: user, skill: skill_1, score: :low)
      insert(:skill_score, user: user, skill: skill_2, score: :high)

      # 通知先となるユーザー（チームメンバー）生成
      user_2 = insert(:user)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      # level: normal になる
      {:ok, _} = SkillScores.update_skill_class_score_stats(skill_class_score, skill_class)

      %{entries: [notification]} =
        Notifications.list_notification_by_type(user_2.id, "skill_update", %{
          page: 1,
          page_size: 1
        })

      assert notification.message == "HogeさんがElixir基本【零細Web開発】で「平均」レベルになりました"
      assert notification.url == "/panels/#{skill_panel.id}/#{user.name}?class=1"
    end

    test "update_skill_class_score_stats with log", %{
      user: user,
      skill_class: skill_class
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      skill_unit = insert(:skill_unit)
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit)
      [%{skills: [skill_1, skill_2]}] = insert_skill_categories_and_skills(skill_unit, [2])

      insert(:skill_score, user: user, skill: skill_1, score: :high)

      # 作成
      {:ok, %{skill_class_score_log: skill_class_score_log}} =
        SkillScores.update_skill_class_score_stats(skill_class_score, skill_class)

      assert skill_class_score_log.percentage == 50.0

      # 更新
      insert(:skill_score, user: user, skill: skill_2, score: :high)

      {:ok, %{skill_class_score_log: skill_class_score_log}} =
        SkillScores.update_skill_class_score_stats(skill_class_score, skill_class)

      assert skill_class_score_log.percentage == 100.0
    end

    test "get_level" do
      [
        {0.0, :beginner},
        {39.9, :beginner},
        {40.0, :normal},
        {59.9, :normal},
        {60.0, :skilled},
        {100.0, :skilled}
      ]
      |> Enum.each(fn {percentage, expected_level} ->
        assert expected_level == SkillScores.get_level(percentage)
      end)
    end
  end

  describe "skill_scores" do
    alias Bright.SkillScores.SkillScore

    @invalid_attrs %{score: :invalid}

    setup do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      skill_unit =
        insert(:skill_unit,
          skill_class_units: [
            %{skill_class_id: skill_class.id, position: 1},
            %{skill_class_id: skill_class_2.id, position: 2}
          ]
        )

      skill_category = insert(:skill_category, skill_unit: skill_unit, position: 1)
      skill = insert(:skill, skill_category: skill_category, position: 1)

      %{user: user, skill_class: skill_class, skill_unit: skill_unit, skill: skill}
    end

    test "list_skill_scores/0 returns all skill_scores", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)

      assert SkillScores.list_skill_scores()
             |> Enum.map(& &1.id) == [skill_score.id]
    end

    test "get_skill_score!/1 returns the skill_score with given id", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      assert SkillScores.get_skill_score!(skill_score.id).id == skill_score.id
    end

    test "update_skill_score/2 with valid data updates the skill_score", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)
      update_attrs = %{score: :high}

      assert {:ok, %SkillScore{} = skill_score} =
               SkillScores.update_skill_score(skill_score, update_attrs)

      assert skill_score.score == :high
    end

    test "update_skill_score/2 with invalid data returns error changeset", %{
      user: user,
      skill: skill
    } do
      skill_score = insert(:skill_score, user: user, skill: skill)

      assert {:error, %Ecto.Changeset{}} =
               SkillScores.update_skill_score(skill_score, @invalid_attrs)

      assert skill_score.score ==
               SkillScores.get_skill_score!(skill_score.id).score
    end

    test "get_user_entered_skill_score_at_least_one? returns true", %{
      user: user,
      skill: skill
    } do
      insert(:skill_score, user: user, skill: skill)
      assert true == SkillScores.get_user_entered_skill_score_at_least_one?(user)
    end

    test "get_user_entered_skill_score_at_least_one? returns false", %{
      user: user
    } do
      assert false == SkillScores.get_user_entered_skill_score_at_least_one?(user)
    end

    test "inserts by insert_or_update_skill_scores", %{user: user, skill: skill} do
      skill_score =
        build(:init_skill_score, user: user, skill: skill, skill_id: skill.id, score: :low)

      refute Repo.get_by(SkillScore, user_id: user.id, skill_id: skill.id)

      {:ok, _} = SkillScores.insert_or_update_skill_scores([skill_score], user)
      assert %{score: :low} = Repo.get_by(SkillScore, user_id: user.id, skill_id: skill.id)
    end

    test "updates by insert_or_update_skill_scores", %{
      user: user,
      skill_class: skill_class,
      skill_unit: skill_unit,
      skill: skill
    } do
      skill_class_score = insert(:init_skill_class_score, user: user, skill_class: skill_class)
      skill_unit_score = insert(:skill_unit_score, user: user, skill_unit: skill_unit)
      skill_score = insert(:skill_score, user: user, skill: skill, score: :low)
      skill_score = Map.put(skill_score, :score, :high)

      {:ok, _} = SkillScores.insert_or_update_skill_scores([skill_score], user)

      assert %{percentage: 100.0} = SkillScores.get_skill_unit_score!(skill_unit_score.id)
      assert %{percentage: 100.0} = SkillScores.get_skill_class_score!(skill_class_score.id)
      assert %{score: :high} = SkillScores.get_skill_score!(skill_score.id)
    end
  end

  describe "skill_unit_scores" do
    alias Bright.SkillScores.{SkillScore, SkillUnitScore}

    test "inserts by insert_or_update_skill_unit_score_stats without score" do
      user = insert(:user)
      skill_unit = insert(:skill_unit)
      [%{skills: [_skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

      refute Repo.get_by(SkillUnitScore, user_id: user.id, skill_unit_id: skill_unit.id)
      {:ok, _results} = SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit], user)

      assert %{percentage: 0.0} =
               Repo.get_by(SkillUnitScore, user_id: user.id, skill_unit_id: skill_unit.id)
    end

    test "inserts by insert_or_update_skill_unit_score_stats" do
      user = insert(:user)
      skill_unit = insert(:skill_unit)
      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      insert(:skill_score, user: user, skill: skill, score: :high)

      refute Repo.get_by(SkillUnitScore, user_id: user.id, skill_unit_id: skill_unit.id)
      {:ok, _results} = SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit], user)

      assert %{percentage: 100.0} =
               Repo.get_by(SkillUnitScore, user_id: user.id, skill_unit_id: skill_unit.id)
    end

    test "updates by insert_or_update_skill_unit_score_stats without score" do
      user = insert(:user)

      # データ準備
      skill_unit = insert(:skill_unit)
      [%{skills: [_skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      skill_unit_score = insert(:skill_unit_score, user: user, skill_unit: skill_unit)

      {:ok, _results} = SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit], user)

      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score.id)
    end

    test "updates by insert_orupdate_skill_unit_score_stats" do
      # 2つのskill_unitsを指定してそれぞれが適当なpercentageになっていることを確認
      user = insert(:user)

      # データ準備
      skill_unit_1 = insert(:skill_unit)
      skill_unit_2 = insert(:skill_unit)
      [%{skills: [skill_1_1]}] = insert_skill_categories_and_skills(skill_unit_1, [1])
      [%{skills: [skill_2_1, skill_2_2]}] = insert_skill_categories_and_skills(skill_unit_2, [2])
      skill_unit_score_1 = insert(:skill_unit_score, user: user, skill_unit: skill_unit_1)
      skill_unit_score_2 = insert(:skill_unit_score, user: user, skill_unit: skill_unit_2)

      # 適当なスキルスコアを用意
      insert(:skill_score, user: user, skill: skill_1_1, score: :low)
      insert(:skill_score, user: user, skill: skill_2_1, score: :high)
      insert(:skill_score, user: user, skill: skill_2_2, score: :low)

      {:ok, _results} =
        SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit_1, skill_unit_2], user)

      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_1.id)
      assert %{percentage: 50.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_2.id)
    end

    test "updates by insert_or_update_skill_unit_score_stats with dummy case" do
      # 他ユーザーのデータを参照していないことの確認用
      # user_1には:high、user_2には:lowをスキルスコアに設定
      user_1 = insert(:user)
      user_2 = insert(:user)

      # データ準備
      skill_unit = insert(:skill_unit)
      [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])
      skill_unit_score_1 = insert(:skill_unit_score, user: user_1, skill_unit: skill_unit)
      skill_unit_score_2 = insert(:skill_unit_score, user: user_2, skill_unit: skill_unit)

      # 適当なスキルスコアを用意
      insert(:skill_score, user: user_1, skill: skill, score: :high)
      insert(:skill_score, user: user_2, skill: skill, score: :low)

      {:ok, _results} = SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit], user_1)
      {:ok, _results} = SkillScores.insert_or_update_skill_unit_scores_stats([skill_unit], user_2)

      assert %{percentage: 100.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_1.id)
      assert %{percentage: 0.0} = Repo.get!(SkillScores.SkillUnitScore, skill_unit_score_2.id)
    end
  end

  # TODO get_skill_gemテスト未実装
  describe "get_skill_gem" do
    test "get_skill_gem" do
    end
  end

  describe "get_skillset_gem" do
    setup [:setup_career_fields]

    test "returns career_fields data and scores", %{career_fields: career_fields} do
      user = insert(:user)
      percentages = [10.0, 20.0, 30.0, 40.0]
      names = Enum.map(career_fields, & &1.name_ja)

      career_fields
      |> Enum.zip(percentages)
      |> Enum.each(fn {career_field, percentage} ->
        insert(:career_field_score, career_field: career_field, user: user, percentage: percentage)
      end)

      ret = SkillScores.get_skillset_gem(user.id)
      assert ^names = Enum.map(ret, & &1.name)
      assert ^percentages = Enum.map(ret, & &1.percentage)

      # ユーザー条件確認
      user_2 = insert(:user)
      ret = SkillScores.get_skillset_gem(user_2.id)
      assert ^names = Enum.map(ret, & &1.name)
      assert [0.0, 0.0, 0.0, 0.0] = Enum.map(ret, & &1.percentage)
    end
  end

  describe "re_aggregate_scores" do
    # 主なテスト対象
    # - skill_unit_scores.pecentage
    # - skill_class_scores.pecentage
    # - skill_class_scores.level
    #
    # 主なテストケース
    # - skillの追加
    # - skillの移動（削除含む）
    # - skill_categoryの追加などはskillと処理上で特に差がないため省略
    # - skill_unitの追加
    # - skill_unitの移動（削除含む）
    # - skill_classの追加と移動 ~ 仕様として存在しない

    # 専用の補助処理
    #
    defp list_skills(skill_unit) do
      skill_unit.skill_categories |> Enum.flat_map(& &1.skills)
    end

    defp list_skill_unit_scores(skill_class) do
      skill_class
      |> Repo.preload([skill_units: [:skill_unit_scores]], force: true)
      |> Map.get(:skill_units)
      # userが1人のため絞り込み省略
      |> Enum.flat_map(& &1.skill_unit_scores)
    end

    defp get_skill_class_scores(skill_panel) do
      skill_panel
      |> Repo.preload([skill_classes: [:skill_class_scores]], force: true)
      |> Map.get(:skill_classes)
      |> Enum.flat_map(& &1.skill_class_scores)
    end

    defp get_skill_class_score_logs(skill_panel) do
      skill_panel
      |> Repo.preload([skill_classes: [:skill_class_score_logs]], force: true)
      |> Map.get(:skill_classes)
      |> Enum.flat_map(& &1.skill_class_score_logs)
    end

    # batch処理での操作想定の各処理
    #
    defp batch_case("none", _context), do: :ok

    defp batch_case("skill_added", %{skill_size: num, skill_unit_1: skill_unit}) do
      [skill_category | _] = skill_unit.skill_categories
      insert_list(num, :skill, skill_category: skill_category)
    end

    defp batch_case("skill_moved", %{skill_unit_1: skill_unit_1, skill_unit_2: skill_unit_2}) do
      [%{skills: [skill_from | _]} | _] = skill_unit_2.skill_categories
      [skill_category_to, _] = skill_unit_1.skill_categories

      skill_from
      |> Ecto.Changeset.change(%{skill_category_id: skill_category_to.id, position: 5})
      |> Repo.update!()
    end

    defp batch_case("skill_moved_to_class2", %{
           skill_unit_1: skill_unit_1,
           skill_unit_c2: skill_unit_to
         }) do
      [%{skills: [skill_from | _]} | _] = skill_unit_1.skill_categories
      [skill_category_to] = skill_unit_to.skill_categories

      skill_from
      |> Ecto.Changeset.change(%{skill_category_id: skill_category_to.id, position: 5})
      |> Repo.update!()
    end

    defp batch_case("skill_unit_added", %{skill_unit_size: scale, skill_class_1: skill_class}) do
      skill_unit =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class.id, position: 3}])

      insert_skill_categories_and_skills(skill_unit, scale)
    end

    defp batch_case("skill_unit_moved_to_class2", %{
           skill_unit_1: skill_unit_1,
           skill_class_2: skill_class_2
         }) do
      [skill_class_unit] = skill_unit_1.skill_class_units

      skill_class_unit
      |> Ecto.Changeset.change(%{skill_class_id: skill_class_2.id, position: 2})
      |> Repo.update!()
    end

    # データ準備: スキルパネル構造
    setup do
      user = insert(:user)
      skill_panel = insert(:skill_panel)

      [skill_class_1, skill_class_2, skill_class_3] =
        Enum.map(1..3, &insert(:skill_class, skill_panel: skill_panel, class: &1))

      # クラス1: スキルユニットから2x2x2で構造定義
      [skill_unit_1, skill_unit_2] =
        Enum.map(1..2, fn position ->
          skill_unit =
            insert(:skill_unit,
              skill_class_units: [%{skill_class_id: skill_class_1.id, position: position}]
            )

          skill_categories = insert_skill_categories_and_skills(skill_unit, [2, 2])

          Map.put(skill_unit, :skill_categories, skill_categories)
        end)

      # クラス2: スキルユニットから1x1x1で構造定義
      skill_unit_c2 =
        insert(:skill_unit, skill_class_units: [%{skill_class_id: skill_class_2.id, position: 1}])
        |> then(fn skill_unit ->
          skill_categories = insert_skill_categories_and_skills(skill_unit, [1])
          Map.put(skill_unit, :skill_categories, skill_categories)
        end)

      %{
        user: user,
        skill_panel: skill_panel,
        skill_class_1: skill_class_1,
        skill_class_2: skill_class_2,
        skill_class_3: skill_class_3,
        skill_unit_1: skill_unit_1,
        skill_unit_2: skill_unit_2,
        skill_unit_c2: skill_unit_c2
      }
    end

    # データ準備: ユーザースコア
    setup %{
      user: user,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2,
      skill_unit_1: skill_unit_1,
      skill_unit_2: skill_unit_2
    } do
      list_skills(skill_unit_1)
      |> Enum.each(&insert(:skill_score, skill: &1, user: user, score: :high))

      insert(:skill_unit_score, skill_unit: skill_unit_1, user: user, percentage: 100.0)
      insert(:skill_unit_score, skill_unit: skill_unit_2, user: user, percentage: 0.0)

      insert(:skill_class_score,
        skill_class: skill_class_1,
        user: user,
        percentage: 50.0,
        level: :normal
      )

      insert(:skill_class_score,
        skill_class: skill_class_2,
        user: user,
        percentage: 0.0,
        level: :beginner
      )

      :ok
    end

    # batchによる影響準備
    setup %{batch: batch} = context do
      batch_case(batch, context)
      :ok
    end

    @tag batch: "none"
    test "runs anyway (no change case)", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2
    } do
      SkillScores.re_aggregate_scores([skill_class_1, skill_class_2])
      [skill_unit_1_score, _] = list_skill_unit_scores(skill_class_1)
      [skill_class_1_score, skill_class_2_score] = get_skill_class_scores(skill_panel)

      assert %{percentage: 100.0} = skill_unit_1_score
      assert %{percentage: 50.0, level: :normal} = skill_class_1_score
      assert %{percentage: 0.0, level: :beginner} = skill_class_2_score
    end

    @tag batch: "skill_added", skill_size: 1
    test "updates skill_unit_scores.percentage case skill added", %{
      skill_class_1: skill_class_1
    } do
      SkillScores.re_aggregate_scores([skill_class_1])
      [skill_unit_1_score, _] = list_skill_unit_scores(skill_class_1)

      # 計算内訳 ()内右の加減算が変更分
      # 4 / (4 + 1)
      assert %{percentage: 80.0} = skill_unit_1_score
    end

    @tag batch: "skill_added", skill_size: 2
    test "updates skill_class_scores.percentage case skill added", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1
    } do
      SkillScores.re_aggregate_scores([skill_class_1])
      [skill_class_1_score, _] = get_skill_class_scores(skill_panel)

      # 4 / (8 + 2)
      assert %{percentage: 40.0} = skill_class_1_score

      # ログ
      [log_1] = get_skill_class_score_logs(skill_panel)
      assert log_1.percentage == 40.0
    end

    @tag batch: "skill_added", skill_size: 8
    test "updates skill_class_scores.level case skill added", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1
    } do
      SkillScores.re_aggregate_scores([skill_class_1])
      [skill_class_1_score, _] = get_skill_class_scores(skill_panel)

      # 4 / (8 + 8)
      assert %{percentage: 25.0, level: :beginner} = skill_class_1_score

      # ログ
      [log_1] = get_skill_class_score_logs(skill_panel)
      assert log_1.percentage == 25.0
    end

    @tag batch: "skill_moved"
    test "updates skill_unit_scores.percentage case skill moved", %{
      skill_class_1: skill_class_1
    } do
      SkillScores.re_aggregate_scores([skill_class_1])

      [skill_unit_1_score, _] = list_skill_unit_scores(skill_class_1)

      # 4 / (4 + 1)
      assert %{percentage: 80.0} = skill_unit_1_score
    end

    @tag batch: "skill_moved_to_class2"
    test "updates skill_unit_scores.percentage case skill moved to class2", %{
      skill_class_2: skill_class_2
    } do
      SkillScores.re_aggregate_scores([skill_class_2])

      # (0 + 1) / (1 + 1)
      [skill_unit_score] = list_skill_unit_scores(skill_class_2)
      assert 50.0 == Float.round(skill_unit_score.percentage, 1)
    end

    @tag batch: "skill_moved_to_class2"
    test "updates skill_class_scores.percentage/level case skill moved to class2", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2
    } do
      SkillScores.re_aggregate_scores([skill_class_1, skill_class_2])
      [skill_class_1_score, skill_class_2_score] = get_skill_class_scores(skill_panel)

      # (4 - 1) / (8 - 1)
      assert 42.9 == Float.round(skill_class_1_score.percentage, 1)

      # (0 + 1) / (1 + 1)
      assert %{percentage: 50.0, level: :normal} = skill_class_2_score

      # ログ
      [log_1, log_2] = get_skill_class_score_logs(skill_panel)
      assert Float.round(log_1.percentage, 1) == 42.9
      assert log_2.percentage == 50.0
    end

    @tag batch: "skill_unit_added", skill_unit_size: [4]
    test "updates skill_class_scores.percentage/level case skill_unit added", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1
    } do
      SkillScores.re_aggregate_scores([skill_class_1])
      [skill_class_1_score, _] = get_skill_class_scores(skill_panel)

      # 4 / (8 + 4)
      assert 33.3 == Float.round(skill_class_1_score.percentage, 1)
      assert %{level: :beginner} = skill_class_1_score

      # ログ
      [log_1] = get_skill_class_score_logs(skill_panel)
      assert Float.round(log_1.percentage, 1) == 33.3
    end

    @tag batch: "skill_unit_moved_to_class2"
    test "updates skill_class_scores.percentage/level case skill_unit moved to class2", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2
    } do
      SkillScores.re_aggregate_scores([skill_class_1, skill_class_2])
      [skill_class_1_score, skill_class_2_score] = get_skill_class_scores(skill_panel)

      # (4 - 4) / (8 - 4)
      assert %{percentage: 0.0, level: :beginner} = skill_class_1_score

      # (0 + 4) / (1 + 4)
      assert %{percentage: 80.0, level: :skilled} = skill_class_2_score

      # ログ
      [log_1, log_2] = get_skill_class_score_logs(skill_panel)
      assert log_1.percentage == 0.0
      assert log_2.percentage == 80.0
    end

    @tag batch: "skill_unit_moved_to_class2"
    test "updates argements only", %{
      skill_panel: skill_panel,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2
    } do
      # skill_class_1を指定、skill_class_2は更新されない
      SkillScores.re_aggregate_scores([skill_class_1])
      [_, skill_class_2_score] = get_skill_class_scores(skill_panel)
      assert %{percentage: 0.0} = skill_class_2_score

      [log] = get_skill_class_score_logs(skill_panel)
      assert log.skill_class_id == skill_class_1.id

      # skill_class_2を指定、更新される
      SkillScores.re_aggregate_scores([skill_class_2])
      [_, skill_class_2_score] = get_skill_class_scores(skill_panel)
      assert %{percentage: 80.0} = skill_class_2_score

      [_, log_2] = get_skill_class_score_logs(skill_panel)
      assert log_2.percentage == 80.0
    end

    @tag batch: "skill_unit_moved_to_class2"
    test "creates notification_skill_updates", %{
      user: user,
      skill_class_1: skill_class_1,
      skill_class_2: skill_class_2
    } do
      user_2 = insert(:user)
      relate_user_and_supporter(user, user_2)

      # 再集計によってskill_class_2がskilledとなる
      SkillScores.re_aggregate_scores([skill_class_1, skill_class_2])

      assert Repo.get_by!(Notifications.NotificationSkillUpdate, %{
               from_user_id: user.id,
               to_user_id: user_2.id
             })
    end
  end

  describe "calc_high_skills_percentage/2" do
    test "returns percentage floored" do
      assert 33 == SkillScores.calc_high_skills_percentage(1, 3)
      assert 66 == SkillScores.calc_high_skills_percentage(2, 3)
    end

    test "returns 0 if size is 0" do
      assert 0 == SkillScores.calc_high_skills_percentage(0, 0)
      assert 0 == SkillScores.calc_high_skills_percentage(1, 0)
    end
  end

  describe "calc_middle_skills_percentage/2" do
    test "returns percentage ceiled" do
      assert 34 == SkillScores.calc_middle_skills_percentage(1, 3)
      assert 67 == SkillScores.calc_middle_skills_percentage(2, 3)
    end

    test "returns 0 if size is 0" do
      assert 0 == SkillScores.calc_middle_skills_percentage(0, 0)
      assert 0 == SkillScores.calc_middle_skills_percentage(1, 0)
    end
  end

  describe "list_skill_class_score_logs/4" do
    setup do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{user: user, skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{user: user, skill_class: skill_class} do
      Date.range(~D[2023-10-01], ~D[2023-10-05])
      |> Enum.each(fn date ->
        insert(:skill_class_score_log, user: user, skill_class: skill_class, date: date)
      end)

      :ok
    end

    test "returns skill_class_score_logs with given condition", %{
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      # 日付範囲を含む各条件での期待結果
      list =
        SkillScores.list_skill_class_score_logs(user, skill_class, ~D[2023-10-02], ~D[2023-10-04])

      assert [~D[2023-10-02], ~D[2023-10-03], ~D[2023-10-04]] == Enum.map(list, & &1.date)

      # ユーザー違いでの空確認
      user_2 = insert(:user)

      list =
        SkillScores.list_skill_class_score_logs(
          user_2,
          skill_class,
          ~D[2023-10-02],
          ~D[2023-10-04]
        )

      assert [] == list

      # スキルクラス違いでの空確認
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      list =
        SkillScores.list_skill_class_score_logs(
          user,
          skill_class_2,
          ~D[2023-10-02],
          ~D[2023-10-04]
        )

      assert [] == list
    end
  end

  describe "list_user_skill_class_score_progress/4" do
    setup do
      user = insert(:user)
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)

      %{user: user, skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{user: user, skill_class: skill_class} do
      [
        {~D[2023-10-01], 10},
        {~D[2023-10-02], 20},
        {~D[2023-10-03], 30},
        {~D[2023-10-03], 32},
        {~D[2023-10-03], 31},
        {~D[2023-10-04], 40},
        {~D[2023-10-04], 42},
        {~D[2023-10-04], 41},
        {~D[2023-10-05], 50}
      ]
      |> Enum.each(fn {date, percentage} ->
        insert(:skill_class_score_log,
          user: user,
          skill_class: skill_class,
          date: date,
          percentage: percentage
        )

        # 並び替えで日付が同じ場合にidを使うが不安定になり落ちるときがあるのでmilisecondだけ待ちを入れている
        :timer.sleep(1)
      end)

      :ok
    end

    test "returns percentage values with given condition", %{
      user: user,
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      # 日付範囲を含む各条件での期待結果
      list =
        SkillScores.list_user_skill_class_score_progress(
          user,
          skill_class,
          ~D[2023-10-02],
          ~D[2023-10-04]
        )

      # 引数指定日内の最新ログは現在相当で扱うので42が正
      assert [20, 31, 42] == list

      # nil埋めと直近データが最後に挿入される確認
      list =
        SkillScores.list_user_skill_class_score_progress(
          user,
          skill_class,
          ~D[2023-10-01],
          ~D[2023-10-06]
        )

      assert [10, 20, 31, nil, nil, 41] == list

      # ユーザー違いでの空確認
      user_2 = insert(:user)

      list =
        SkillScores.list_user_skill_class_score_progress(
          user_2,
          skill_class,
          ~D[2023-10-02],
          ~D[2023-10-04]
        )

      assert [nil, nil, nil] == list

      # スキルクラス違いでの空確認
      skill_class_2 = insert(:skill_class, skill_panel: skill_panel, class: 2)

      list =
        SkillScores.list_user_skill_class_score_progress(
          user,
          skill_class_2,
          ~D[2023-10-02],
          ~D[2023-10-04]
        )

      assert [nil, nil, nil] == list
    end

    test "returns zero value when latest log is existing only", %{
      skill_class: skill_class
    } do
      # 初めての入力後は直前スコアがないため0が打たれる
      user = insert(:user)

      insert(:skill_class_score_log,
        user: user,
        skill_class: skill_class,
        date: ~D[2023-10-04],
        percentage: 40
      )

      list =
        SkillScores.list_user_skill_class_score_progress(
          user,
          skill_class,
          ~D[2023-10-01],
          ~D[2023-10-04]
        )

      assert [nil, nil, nil, 0] == list
    end

    test "returns historical value when latest log is existing only", %{
      skill_panel: skill_panel,
      skill_class: skill_class
    } do
      # 該当期間での初めての入力後は期間前のスキルクラススコア履歴からデータを取る
      user = insert(:user)

      insert(:skill_class_score_log,
        user: user,
        skill_class: skill_class,
        date: ~D[2023-10-04],
        percentage: 40
      )

      # スキルクラススコア履歴データ
      [
        {~D[2023-07-01], 20},
        {~D[2023-10-01], 30},
        {~D[2024-01-01], 50}
      ]
      |> Enum.each(fn {date, percentage} ->
        historical_skill_class =
          build(
            :historical_skill_class,
            skill_panel_id: skill_panel.id,
            trace_id: skill_class.trace_id,
            locked_date: Timex.shift(date, months: -3)
          )

        insert(:historical_skill_class_score,
          user: user,
          historical_skill_class: historical_skill_class,
          locked_date: date,
          percentage: percentage
        )
      end)

      list =
        SkillScores.list_user_skill_class_score_progress(
          user,
          skill_class,
          ~D[2023-10-01],
          ~D[2023-10-04]
        )

      # 1つ前（2023-10-01）のスキルクラススコア履歴が採用されていること
      assert [nil, nil, nil, 30] == list
    end
  end
end
