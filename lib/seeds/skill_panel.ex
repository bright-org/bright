defmodule Bright.Seeds.SkillPanel do
  @moduledoc """
  開発用のスキルパネルSeedデータ
  """

  alias Bright.{Repo, SkillPanels, SkillUnits, CareerFields}
  alias Bright.SkillPanels.{SkillPanel, SkillClass}
  alias Bright.SkillUnits.{SkillClassUnit, SkillUnit, SkillCategory, Skill}
  alias Bright.SkillScores.{CareerFieldScore, SkillClassScore, SkillUnitScore, SkillScore}
  alias Bright.UserSkillPanels.UserSkillPanel

  def skill_panel(panel_name, career_field) do
    %{
      name: "#{career_field.name_ja} スキルパネル#{panel_name}",
      skill_classes: [
        %{name: "#{panel_name}-クラス1", class: 1},
        %{name: "#{panel_name}-クラス2", class: 2},
        %{name: "#{panel_name}-クラス3", class: 3}
      ]
    }
  end

  def skill_unit(skill_class, position) do
    %{
      name: "#{position}-スキルユニット(class:#{skill_class.class})",
      skill_categories:
        for x <- 1..3 do
          skill_categories(position, x, skill_class)
        end,
      skill_class_units: [
        %{skill_class_id: skill_class.id, position: position}
      ]
    }
  end

  def skill_categories(panel_name, no, skill_class) do
    %{
      name: "#{panel_name}-#{no}カテゴリ(class:#{skill_class.class})",
      position: no,
      skills:
        for x <- 1..3 do
          %{name: "#{panel_name}-#{no}-#{x}-スキル(class:#{skill_class.class})", position: x}
        end
    }
  end

  def create_skill_unit(skill_class) do
    for x <- 1..Enum.random([5, 6, 7, 8, 9, 10]) do
      {:ok, _skill_unit} = SkillUnits.create_skill_unit(skill_unit(skill_class, x))
    end
  end

  def create_panel(panel_name, career_field) do
    {:ok, skill_panel} = SkillPanels.create_skill_panel(skill_panel(panel_name, career_field))

    skill_panel.skill_classes |> Enum.each(&create_skill_unit/1)
  end

  def insert do
    CareerFields.list_career_fields()
    |> Enum.each(fn c ->
      1..4
      |> Enum.each(fn i -> create_panel(i, c) end)
    end)
  end

  def delete do
    [
      SkillScore,
      SkillUnitScore,
      SkillClassScore,
      CareerFieldScore,
      Skill,
      SkillCategory,
      SkillClassUnit,
      SkillUnit,
      SkillClass,
      UserSkillPanel,
      SkillPanel
    ]
    |> Enum.each(fn s ->
      s
      |> Repo.all()
      |> Enum.each(&Repo.delete(&1))
    end)
  end
end
