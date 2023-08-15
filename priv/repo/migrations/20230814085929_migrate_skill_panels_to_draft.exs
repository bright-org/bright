defmodule Bright.Repo.Migrations.MigrateSkillPanelsToDraft do
  use Ecto.Migration

  alias Bright.Repo
  alias Bright.SkillUnits.SkillUnit

  alias Bright.DraftSkillUnits.{
    DraftSkillUnit,
    DraftSkillCategory,
    DraftSkill,
    DraftSkillClassUnit
  }

  alias Bright.SkillPanels.SkillClass
  alias Bright.DraftSkillPanels.DraftSkillClass

  def up do
    Repo.transaction(fn ->
      draft_skill_unit_pairs =
        SkillUnit
        |> Repo.all()
        |> Repo.preload(skill_categories: :skills)
        |> Enum.map(fn skill_unit ->
          {:ok, draft_skill_unit} =
            Repo.insert(%DraftSkillUnit{
              trace_id: skill_unit.trace_id,
              name: skill_unit.name
            })

          Enum.each(skill_unit.skill_categories, fn skill_category ->
            {:ok, draft_skill_category} =
              Repo.insert(%DraftSkillCategory{
                draft_skill_unit: draft_skill_unit,
                trace_id: skill_category.trace_id,
                name: skill_category.name,
                position: skill_category.position
              })

            Enum.each(skill_category.skills, fn skill ->
              {:ok, _draft_skill} =
                Repo.insert(%DraftSkill{
                  draft_skill_category: draft_skill_category,
                  trace_id: skill.trace_id,
                  name: skill.name,
                  position: skill.position
                })
            end)
          end)

          {draft_skill_unit, skill_unit}
        end)

      SkillClass
      |> Repo.all()
      |> Repo.preload(:skill_class_units)
      |> Enum.each(fn skill_class ->
        {:ok, draft_skill_class} =
          Repo.insert(%DraftSkillClass{
            skill_panel_id: skill_class.skill_panel_id,
            trace_id: skill_class.trace_id,
            name: skill_class.name,
            class: skill_class.class
          })

        Enum.each(skill_class.skill_class_units, fn skill_class_unit ->
          {draft_skill_unit, _skill_unit} =
            Enum.find(draft_skill_unit_pairs, fn {_draft_skill_unit, skill_unit} ->
              skill_unit.id == skill_class_unit.skill_unit_id
            end)

          {:ok, _} =
            Repo.insert(%DraftSkillClassUnit{
              draft_skill_class: draft_skill_class,
              draft_skill_unit: draft_skill_unit,
              trace_id: skill_class_unit.trace_id,
              position: skill_class_unit.position
            })
        end)
      end)
    end)
  end

  def down do
    Repo.transaction(fn ->
      Repo.delete_all(DraftSkillClassUnit)
      Repo.delete_all(DraftSkillClass)
      Repo.delete_all(DraftSkill)
      Repo.delete_all(DraftSkillCategory)
      Repo.delete_all(DraftSkillUnit)
    end)
  end
end
