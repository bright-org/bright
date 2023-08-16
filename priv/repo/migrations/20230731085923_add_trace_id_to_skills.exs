defmodule Bright.Repo.Migrations.AddLockedDateAndTraceIdToSkills do
  use Ecto.Migration

  alias Bright.Repo
  alias Bright.SkillUnits.Skill

  def up do
    alter table(:skills) do
      add :trace_id, :uuid
    end

    flush()

    Enum.each(Repo.all(Skill), fn skill ->
      {:ok, _} =
        skill
        |> Ecto.Changeset.cast(%{trace_id: Ecto.ULID.generate()}, [:trace_id])
        |> Repo.update()
    end)

    flush()

    alter table(:skills) do
      modify :trace_id, :uuid, null: false
    end
  end

  def down do
    alter table(:skills) do
      remove :trace_id
    end
  end
end
