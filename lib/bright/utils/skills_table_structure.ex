defmodule Bright.Utils.SkillsTableStructure do
  @moduledoc """
  スキルをテーブルで一覧表示するための構造を扱うモジュール
  """

  alias Bright.SkillUnits
  alias Bright.DraftSkillUnits
  alias Bright.HistoricalSkillUnits

  @doc """
  スキルユニット一覧をスキル構造をテーブル表示で扱う形式に変換

  出力サンプル:
  [
    [%{size: 5, skill_unit: %SkillUnit{}}, %{size: 2, skill_category: %SkillCategory{}}, %{skill: %Skill{}}],
    [nil, nil, %{skill: %Skill{}}],
    [nil, %{size: 3, skill_category: %SkillCategory{}}, %{skill: %Skill{}}],
    [nil, nil, %{skill: %Skill{}}],
    [nil, nil, %{skill: %Skill{}}]
  ]
  """
  def build(skill_units) do
    skill_units
    |> Enum.with_index(1)
    |> Enum.flat_map(fn {skill_unit, position} ->
      skill_category_items =
        list_skill_categories(skill_unit)
        |> Enum.flat_map(&build_skill_category_table_structure/1)

      build_skill_unit_table_structure(skill_unit, skill_category_items, position)
    end)
  end

  defp build_skill_category_table_structure(skill_category) do
    skills = list_skills(skill_category)
    size = length(skills)
    skill_category_item = %{size: size, skill_category: skill_category}

    skills
    |> Enum.with_index(1)
    |> Enum.map(fn
      {skill, 1} -> [skill_category_item] ++ [%{skill: skill, first: true}]
      {skill, ^size} -> [nil] ++ [%{skill: skill, last: true}]
      {skill, _i} -> [nil] ++ [%{skill: skill}]
    end)
  end

  defp build_skill_unit_table_structure(skill_unit, skill_category_items, position) do
    size =
      skill_category_items
      |> Enum.reduce(0, fn
        [nil, _], acc -> acc
        [%{size: size}, _], acc -> acc + size
      end)

    skill_unit_item = %{size: size, skill_unit: skill_unit, position: position}

    skill_category_items
    |> Enum.with_index()
    |> Enum.map(fn
      {skill_category_item, 0} -> [skill_unit_item] ++ skill_category_item
      {skill_category_item, _i} -> [nil] ++ skill_category_item
    end)
  end

  defp list_skill_categories(%SkillUnits.SkillUnit{} = skill_unit) do
    skill_unit.skill_categories
  end

  defp list_skill_categories(%DraftSkillUnits.DraftSkillUnit{} = skill_unit) do
    skill_unit.draft_skill_categories
  end

  defp list_skill_categories(%HistoricalSkillUnits.HistoricalSkillUnit{} = skill_unit) do
    skill_unit.historical_skill_categories
  end

  defp list_skills(%SkillUnits.SkillCategory{} = skill_category) do
    skill_category.skills
  end

  defp list_skills(%DraftSkillUnits.DraftSkillCategory{} = skill_category) do
    skill_category.draft_skills
  end

  defp list_skills(%HistoricalSkillUnits.HistoricalSkillCategory{} = skill_category) do
    skill_category.historical_skills
  end
end
