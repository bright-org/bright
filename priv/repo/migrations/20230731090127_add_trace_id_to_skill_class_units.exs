defmodule Bright.Repo.Migrations.AddLockedDateAndTraceIdToSkillClassUnits do
  use Ecto.Migration

  alias Bright.Repo
  alias Bright.SkillUnits.SkillClassUnit

  def up do
    alter table(:skill_class_units) do
      add :trace_id, :uuid
    end

    flush()

    Enum.each(Repo.all(SkillClassUnit), fn skill_class_unit ->
      {:ok, _} =
        skill_class_unit
        |> Ecto.Changeset.cast(%{trace_id: Ecto.ULID.generate()}, [:trace_id])
        |> Repo.update()
    end)

    flush()

    alter table(:skill_class_units) do
      modify :trace_id, :uuid, null: false
    end
  end

  def down do
    alter table(:skill_class_units) do
      remove :trace_id
    end
  end
end
