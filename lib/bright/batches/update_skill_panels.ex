defmodule Bright.Batches.UpdateSkillPanels do
  @moduledoc """
  スキルパネルを更新するバッチ。

  https://github.com/bright-org/bright/blob/develop/docs/logics/update_skill_panels.md
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.DraftSkillUnits.DraftSkillUnit
  alias Bright.DraftSkillPanels.DraftSkillClass

  alias Bright.SkillUnits.{SkillUnit, SkillCategory, Skill, SkillClassUnit}
  alias Bright.SkillPanels.{SkillPanel, SkillClass}
  alias Bright.SkillScores.{SkillUnitScore, SkillScore, SkillClassScore}

  alias Bright.HistoricalSkillUnits.{
    HistoricalSkillUnit,
    HistoricalSkillCategory,
    HistoricalSkill,
    HistoricalSkillClassUnit
  }

  alias Bright.HistoricalSkillPanels.HistoricalSkillClass

  alias Bright.HistoricalSkillScores.{
    HistoricalSkillUnitScore,
    HistoricalSkillScore,
    HistoricalSkillClassScore,
    HistoricalCareerFieldScore
  }

  def call(locked_date \\ nil) do
    skill_panels = Repo.all(SkillPanel)
    now = NaiveDateTime.local_now()
    locked_date = if locked_date, do: locked_date, else: Date.utc_today()

    Repo.transaction(fn ->
      # 公開データから履歴データを生成
      skill_unit_pairs = create_historical_skill_units(now)
      create_historical_skill_unit_scores(skill_unit_pairs, now, locked_date)

      skill_pairs = Enum.flat_map(skill_unit_pairs, fn {skill_unit, historical_skill_unit} ->
        skill_category_pairs =
          create_historical_skill_categories(
            skill_unit.skill_categories,
            historical_skill_unit,
            now
          )

        # credo:disable-for-next-line
        Enum.flat_map(skill_category_pairs, fn {skill_category, historical_skill_category} ->
          create_historical_skills(skill_category.skills, historical_skill_category, now)
        end)
      end)

      create_historical_skill_scores(skill_pairs, now)

      skill_class_pairs = Enum.flat_map(skill_panels, fn %{id: skill_panel_id} ->
        skill_class_pairs = create_historical_skill_classes(skill_panel_id, now)
        create_historical_skill_class_units(skill_class_pairs, skill_unit_pairs, now)

        skill_class_pairs
      end)

      create_historical_skill_class_scores(skill_class_pairs, now, locked_date)
      create_historical_career_field_scores(now, locked_date)

      # 運営下書きデータから公開データを生成
      draft_skill_unit_pairs = create_skill_units(now, locked_date)
      create_skill_unit_scores(draft_skill_unit_pairs, now)

      draft_skill_pairs = Enum.flat_map(draft_skill_unit_pairs, fn {draft_skill_unit, skill_unit} ->
        draft_skill_category_pairs =
          create_skill_categories(
            draft_skill_unit.draft_skill_categories,
            skill_unit,
            now
          )

        # credo:disable-for-next-line
        Enum.flat_map(draft_skill_category_pairs, fn {draft_skill_category, skill_category} ->
          create_skills(draft_skill_category.draft_skills, skill_category, now)
        end)
      end)

      create_skill_scores(draft_skill_pairs, now)

      draft_skill_class_pairs = Enum.flat_map(skill_panels, fn %{id: skill_panel_id} ->
        draft_skill_class_pairs = create_skill_classes(skill_panel_id, now, locked_date)
        create_skill_class_units(draft_skill_class_pairs, draft_skill_unit_pairs, now)

        draft_skill_class_pairs
      end)

      create_skill_class_scores(draft_skill_class_pairs, now)
      # create_career_field_scores(now, locked_date)

      # コピー元の公開データを削除
      delete_old_skill_classes(locked_date)
      delete_old_skill_units(locked_date)
    end)
  end

  defp create_historical_skill_units(now) do
    skill_units =
      Repo.all(
        from su in SkillUnit,
          preload: [:skill_unit_scores, skill_categories: [skills: :skill_scores]]
      )

    entries =
      Enum.map(skill_units, fn skill_unit ->
        %{
          id: Ecto.ULID.generate(),
          locked_date: skill_unit.locked_date,
          trace_id: skill_unit.trace_id,
          name: skill_unit.name,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(HistoricalSkillUnit, entries)

    skill_units
    |> Enum.with_index()
    |> Enum.map(fn {skill_unit, i} ->
      {skill_unit, struct(HistoricalSkillUnit, Enum.at(entries, i))}
    end)
  end

  defp create_historical_skill_categories(skill_categories, historical_skill_unit, now) do
    entries =
      Enum.map(skill_categories, fn skill_category ->
        %{
          id: Ecto.ULID.generate(),
          historical_skill_unit_id: historical_skill_unit.id,
          trace_id: skill_category.trace_id,
          name: skill_category.name,
          position: skill_category.position,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(HistoricalSkillCategory, entries)

    skill_categories
    |> Enum.with_index()
    |> Enum.map(fn {skill_category, i} ->
      {skill_category, struct(HistoricalSkillCategory, Enum.at(entries, i))}
    end)
  end

  defp create_historical_skills(skills, historical_skill_category, now) do
    entries =
      Enum.map(skills, fn skill ->
        %{
          id: Ecto.ULID.generate(),
          historical_skill_category_id: historical_skill_category.id,
          trace_id: skill.trace_id,
          name: skill.name,
          position: skill.position,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(HistoricalSkill, entries)

    skills
    |> Enum.with_index()
    |> Enum.map(fn {skill, i} ->
      {skill, struct(HistoricalSkill, Enum.at(entries, i))}
    end)
  end

  defp create_historical_skill_classes(skill_panel_id, now) do
    skill_classes =
      Repo.all(
        from sc in SkillClass,
          where: sc.skill_panel_id == ^skill_panel_id,
          preload: [:skill_class_units, :skill_class_scores]
      )

    entries =
      Enum.map(skill_classes, fn skill_class ->
        %{
          id: Ecto.ULID.generate(),
          skill_panel_id: skill_class.skill_panel_id,
          locked_date: skill_class.locked_date,
          trace_id: skill_class.trace_id,
          name: skill_class.name,
          class: skill_class.class,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(HistoricalSkillClass, entries)

    skill_classes
    |> Enum.with_index()
    |> Enum.map(fn {skill_class, i} ->
      {skill_class, struct(HistoricalSkillClass, Enum.at(entries, i))}
    end)
  end

  defp create_historical_skill_class_units(skill_class_pairs, skill_unit_pairs, now) do
    entries =
      Enum.flat_map(skill_class_pairs, fn {skill_class, historical_skill_class} ->
        Enum.map(skill_class.skill_class_units, fn skill_class_unit ->
          {_skill_unit, historical_skill_unit} =
            Enum.find(skill_unit_pairs, fn {skill_unit, _} ->
              skill_unit.id == skill_class_unit.skill_unit_id
            end)

          %{
            id: Ecto.ULID.generate(),
            historical_skill_class_id: historical_skill_class.id,
            historical_skill_unit_id: historical_skill_unit.id,
            trace_id: skill_class_unit.trace_id,
            position: skill_class_unit.position,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)

    Repo.insert_all(HistoricalSkillClassUnit, entries)
  end

  defp create_historical_skill_unit_scores(skill_unit_pairs, now, locked_date) do
    entries =
      Enum.flat_map(skill_unit_pairs, fn {skill_unit, historical_skill_unit} ->
        Enum.map(skill_unit.skill_unit_scores, fn skill_unit_score ->
          %{
            id: Ecto.ULID.generate(),
            user_id: skill_unit_score.user_id,
            historical_skill_unit_id: historical_skill_unit.id,
            locked_date: locked_date,
            percentage: skill_unit_score.percentage,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)

    Repo.insert_all(HistoricalSkillUnitScore, entries)
  end

  defp create_historical_skill_scores(skill_pairs, now) do
    entries =
      Enum.flat_map(skill_pairs, fn {skill, historical_skill} ->
        Enum.map(skill.skill_scores, fn skill_score ->
          %{
            id: Ecto.ULID.generate(),
            user_id: skill_score.user_id,
            historical_skill_id: historical_skill.id,
            score: skill_score.score,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)

    Repo.insert_all(HistoricalSkillScore, entries)
  end

  defp create_historical_skill_class_scores(skill_class_pairs, now, locked_date) do
    entries =
      Enum.flat_map(skill_class_pairs, fn {skill_class, historical_skill_class} ->
        Enum.map(skill_class.skill_class_scores, fn skill_class_score ->
          %{
            id: Ecto.ULID.generate(),
            user_id: skill_class_score.user_id,
            historical_skill_class_id: historical_skill_class.id,
            locked_date: locked_date,
            level: skill_class_score.level,
            percentage: skill_class_score.percentage,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)

    Repo.insert_all(HistoricalSkillClassScore, entries)
  end

  defp create_historical_career_field_scores(now, locked_date) do
    entries =
      Bright.SkillScores.CareerFieldScore
      |> Repo.all()
      |> Enum.map(fn career_field_score ->
        %{
          id: Ecto.ULID.generate(),
          user_id: career_field_score.user_id,
          career_field_id: career_field_score.career_field_id,
          locked_date: locked_date,
          percentage: career_field_score.percentage,
          high_skills_count: career_field_score.high_skills_count,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(HistoricalCareerFieldScore, entries)
  end

  defp create_skill_units(now, locked_date) do
    draft_skill_units = Repo.all(from dsu in DraftSkillUnit, preload: [draft_skill_categories: :draft_skills])
    entries =
      Enum.map(draft_skill_units, fn draft_skill_unit ->
        %{
          id: Ecto.ULID.generate(),
          locked_date: locked_date,
          trace_id: draft_skill_unit.trace_id,
          name: draft_skill_unit.name,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(SkillUnit, entries)

    draft_skill_units
    |> Enum.with_index()
    |> Enum.map(fn {draft_skill_unit, i} ->
      {draft_skill_unit, struct(SkillUnit, Enum.at(entries, i))}
    end)
  end

  defp create_skill_categories(draft_skill_categories, skill_unit, now) do
    entries =
      Enum.map(draft_skill_categories, fn draft_skill_category ->
        %{
          id: Ecto.ULID.generate(),
          skill_unit_id: skill_unit.id,
          trace_id: draft_skill_category.trace_id,
          name: draft_skill_category.name,
          position: draft_skill_category.position,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(SkillCategory, entries)

    draft_skill_categories
    |> Enum.with_index()
    |> Enum.map(fn {draft_skill_category, i} ->
      {draft_skill_category, struct(SkillCategory, Enum.at(entries, i))}
    end)
  end

  defp create_skills(draft_skills, skill_category, now) do
    entries =
      Enum.map(draft_skills, fn draft_skill ->
        %{
          id: Ecto.ULID.generate(),
          skill_category_id: skill_category.id,
          trace_id: draft_skill.trace_id,
          name: draft_skill.name,
          position: draft_skill.position,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Skill, entries)

    draft_skills
    |> Enum.with_index()
    |> Enum.map(fn {draft_skill, i} ->
      {draft_skill, struct(Skill, Enum.at(entries, i))}
    end)
  end

  defp create_skill_classes(skill_panel_id, now, locked_date) do
    draft_skill_classes =
      Repo.all(
        from sc in DraftSkillClass,
          where: sc.skill_panel_id == ^skill_panel_id,
          preload: [:draft_skill_class_units]
      )

    entries =
      Enum.map(draft_skill_classes, fn draft_skill_class ->
        %{
          id: Ecto.ULID.generate(),
          skill_panel_id: draft_skill_class.skill_panel_id,
          locked_date: locked_date,
          trace_id: draft_skill_class.trace_id,
          name: draft_skill_class.name,
          class: draft_skill_class.class,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(SkillClass, entries)

    draft_skill_classes
    |> Enum.with_index()
    |> Enum.map(fn {draft_skill_class, i} ->
      {draft_skill_class, struct(SkillClass, Enum.at(entries, i))}
    end)
  end

  defp create_skill_class_units(draft_skill_class_pairs, draft_skill_unit_pairs, now) do
    entries =
      Enum.flat_map(draft_skill_class_pairs, fn {draft_skill_class, skill_class} ->
        Enum.map(draft_skill_class.draft_skill_class_units, fn draft_skill_class_unit ->
          {_draft_skill_unit, skill_unit} =
            Enum.find(draft_skill_unit_pairs, fn {draft_skill_unit, _} ->
              draft_skill_unit.id == draft_skill_class_unit.draft_skill_unit_id
            end)

          %{
            id: Ecto.ULID.generate(),
            skill_class_id: skill_class.id,
            skill_unit_id: skill_unit.id,
            trace_id: draft_skill_class_unit.trace_id,
            position: draft_skill_class_unit.position,
            inserted_at: now,
            updated_at: now
          }
        end)
      end)

    Repo.insert_all(SkillClassUnit, entries)
  end

  defp create_skill_unit_scores(draft_skill_unit_pairs, now) do
    old_skill_unit_scores = Repo.all(from SkillUnitScore, preload: [:skill_unit])

    entries =
      old_skill_unit_scores
      |> Enum.map(fn old_skill_unit_score ->
        {_draft_skill_unit, skill_unit} = Enum.find(draft_skill_unit_pairs, fn {_draft_skill_unit, skill_unit} ->
          skill_unit.trace_id == old_skill_unit_score.skill_unit.trace_id
        end)

        if skill_unit do
          %{
            id: Ecto.ULID.generate(),
            user_id: old_skill_unit_score.user_id,
            skill_unit_id: skill_unit.id,
            percentage: old_skill_unit_score.percentage,
            inserted_at: now,
            updated_at: now
          }
        end
      end)
      |> Enum.reject(&is_nil/1)

    Repo.delete_all(SkillUnitScore)
    Repo.insert_all(SkillUnitScore, entries)
  end

  defp create_skill_scores(draft_skill_pairs, now) do
    old_skill_scores = Repo.all(from SkillScore, preload: [:skill])

    entries =
      old_skill_scores
      |> Enum.map(fn old_skill_score ->
        {_draft_skill, skill} = Enum.find(draft_skill_pairs, fn {_draft_skill, skill} ->
          skill.trace_id == old_skill_score.skill.trace_id
        end)

        if skill do
          %{
            id: Ecto.ULID.generate(),
            user_id: old_skill_score.user_id,
            skill_id: skill.id,
            score: old_skill_score.score,
            inserted_at: now,
            updated_at: now
          }
        end
      end)
      |> Enum.reject(&is_nil/1)

    Repo.delete_all(SkillScore)
    Repo.insert_all(SkillScore, entries)
  end

  defp create_skill_class_scores(draft_skill_class_pairs, now) do
    old_skill_class_scores = Repo.all(from SkillClassScore, preload: [:skill_class])

    entries =
      old_skill_class_scores
      |> Enum.map(fn old_skill_class_score ->
        {_draft_skill_class, skill_class} = Enum.find(draft_skill_class_pairs, fn {_draft_skill_class, skill_class} ->
          skill_class.trace_id == old_skill_class_score.skill_class.trace_id
        end)

        if skill_class do
          %{
            id: Ecto.ULID.generate(),
            user_id: old_skill_class_score.user_id,
            skill_class_id: skill_class.id,
            level: old_skill_class_score.level,
            percentage: old_skill_class_score.percentage,
            inserted_at: now,
            updated_at: now
          }
        end
      end)

    Repo.delete_all(SkillClassScore, entries)
    Repo.insert_all(SkillClassScore, entries)
  end

  defp delete_old_skill_classes(locked_date) do
    from(scu in SkillClassUnit,
      join: sc in assoc(scu, :skill_class),
      where: sc.locked_date < ^locked_date
    )
    |> Repo.delete_all()

    from(sc in SkillClass, where: sc.locked_date < ^locked_date)
    |> Repo.delete_all()
  end

  defp delete_old_skill_units(locked_date) do
    from(s in Skill,
      join: sc in assoc(s, :skill_category),
      join: su in assoc(sc, :skill_unit),
      where: su.locked_date < ^locked_date
    )
    |> Repo.delete_all()

    from(sc in SkillCategory,
      join: su in assoc(sc, :skill_unit),
      where: su.locked_date < ^locked_date
    )
    |> Repo.delete_all()

    from(su in SkillUnit, where: su.locked_date < ^locked_date)
    |> Repo.delete_all()
  end
end
