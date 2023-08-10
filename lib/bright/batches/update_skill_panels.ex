defmodule Bright.Batches.UpdateSkillPanels do
  @moduledoc """
  スキルパネルを更新するバッチ。

  https://github.com/bright-org/bright/blob/develop/docs/logics/update_skill_panels.md
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillUnits.SkillUnit
  alias Bright.SkillPanels.{SkillPanel, SkillClass}

  alias Bright.HistoricalSkillUnits.{
    HistoricalSkillUnit,
    HistoricalSkillCategory,
    HistoricalSkill,
    HistoricalSkillClassUnit
  }

  alias Bright.HistoricalSkillPanels.HistoricalSkillClass
  alias Bright.HistoricalSkillScores.{HistoricalSkillScore, HistoricalSkillClassScore}

  def call(locked_date \\ nil) do
    skill_panels = Repo.all(SkillPanel)
    now = NaiveDateTime.local_now()
    locked_date = if locked_date, do: locked_date, else: Date.utc_today()

    Repo.transaction(fn ->
      skill_unit_pairs = create_historical_skill_units(now)

      Enum.each(skill_unit_pairs, fn {skill_unit, historical_skill_unit} ->
        skill_category_pairs =
          create_historical_skill_categories(
            skill_unit.skill_categories,
            historical_skill_unit,
            now
          )

        Enum.each(skill_category_pairs, fn {skill_category, historical_skill_category} ->
          skill_pairs =
            create_historical_skills(skill_category.skills, historical_skill_category, now)

          create_historical_skill_scores(skill_pairs, now)
        end)
      end)

      Enum.each(skill_panels, fn %{id: skill_panel_id} ->
        skill_class_pairs = create_historical_skill_classes(skill_panel_id, now)
        create_historical_skill_class_units(skill_class_pairs, skill_unit_pairs, now)
        create_historical_skill_class_scores(skill_class_pairs, now, locked_date)
      end)
    end)
  end

  defp create_historical_skill_units(now) do
    skill_units =
      Repo.all(from su in SkillUnit, preload: [skill_categories: [skills: :skill_scores]])

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
end
