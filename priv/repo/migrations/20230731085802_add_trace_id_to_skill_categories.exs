defmodule Bright.Repo.Migrations.AddLockedDateAndTraceIdToSkillCategories do
  use Ecto.Migration

  alias Bright.Repo
  alias Bright.SkillUnits.SkillCategory

  def up do
    alter table(:skill_categories) do
      add :trace_id, :uuid
    end

    flush()

    Enum.each(Repo.all(SkillCategory), fn skill_category ->
      {:ok, _} =
        skill_category
        |> Ecto.Changeset.cast(%{trace_id: Ecto.ULID.generate()}, [:trace_id])
        |> Repo.update()
    end)

    flush()

    alter table(:skill_categories) do
      modify :trace_id, :uuid, null: false
    end
  end

  def down do
    alter table(:skill_categories) do
      remove :trace_id
    end
  end
end
