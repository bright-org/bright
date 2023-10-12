defmodule Bright.Repo.Migrations.AddLockedDateAndTraceIdToSkillUnits do
  use Ecto.Migration

  alias Bright.Repo
  alias Bright.SkillUnits.SkillUnit

  def up do
    alter table(:skill_units) do
      add :locked_date, :date
      add :trace_id, :uuid
    end

    flush()

    Enum.each(Repo.all(SkillUnit), fn skill_unit ->
      {:ok, _} =
        skill_unit
        |> Ecto.Changeset.cast(%{locked_date: ~D[2023-07-01], trace_id: Ecto.ULID.generate()}, [
          :locked_date,
          :trace_id
        ])
        |> Repo.update()
    end)

    flush()

    alter table(:skill_units) do
      modify :locked_date, :date, null: false
      modify :trace_id, :uuid, null: false
    end
  end

  def down do
    alter table(:skill_units) do
      remove :locked_date
      remove :trace_id
    end
  end
end
