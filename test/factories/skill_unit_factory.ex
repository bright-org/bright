defmodule Bright.SkillUnitFactory do
  @moduledoc """
  Factory for Bright.SkillUnits.SkillUnit
  """

  defmacro __using__(_opts) do
    quote do
      def skill_unit_factory do
        %Bright.SkillUnits.SkillUnit{
          name: Faker.Lorem.word()
        }
      end

      # スキルユニットのカテゴリとスキル生成用ヘルパ
      #
      # categories_num_skills:
      #   それぞれのスキルカテゴリに作成するスキル数を格納した配列
      #   [2,1,1] ~ 3つのスキルカテゴリを生成し、最初のスキルカテゴリには2つのスキルを生成
      def insert_skill_categories_and_skills(skill_unit, categories_num_skills) do
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
    end
  end
end
