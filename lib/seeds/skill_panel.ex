defmodule Bright.Seeds.SkillPanel do
  @moduledoc """
  開発用のスキルパネルSeedデータ
  """

  alias Bright.{Repo, SkillPanels, SkillUnits}
  alias Bright.SkillPanels.{SkillPanel, SkillClass}
  alias Bright.SkillUnits.{SkillClassUnit, SkillUnit, SkillCategory, Skill}

  def skill_panel(panel_name) do
    %{
      name: "スキルパネル名#{panel_name}",
      skill_classes: [
        %{name: "#{panel_name}-クラス1", class: 1},
        %{name: "#{panel_name}-クラス2", class: 2},
        %{name: "#{panel_name}-クラス3", class: 3}
      ]
    }
  end

  def skill_unit(skill_class, panel_name) do
    %{
      name: "#{panel_name}-スキルユニット(class:#{skill_class.class})",
      skill_categories:
        for x <- 1..3 do
          skill_categories(panel_name, x, skill_class)
        end,
      skill_class_units: [
        %{skill_class_id: skill_class.id, position: 1}
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
    for x <- 1..5 do
      {:ok, _skill_unit} = SkillUnits.create_skill_unit(skill_unit(skill_class, x))
    end
  end

  def create_panel(panel_name) do
    {:ok, skill_panel} = SkillPanels.create_skill_panel(skill_panel(panel_name))
    skill_panel.skill_classes |> Enum.each(&create_skill_unit/1)
  end

  def insert do
    1..13
    |> Enum.each(&create_panel/1)
  end

  def delete do
    [Skill, SkillCategory, SkillClassUnit, SkillUnit, SkillClass, SkillPanel]
    |> Enum.each(fn s ->
      s
      |> Repo.all()
      |> Enum.each(&Repo.delete(&1))
    end)
  end
end
