defmodule Bright.SkillExams.SkillExam do
  @moduledoc """
  スキル試験を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_exams" do
    belongs_to(:skill, Bright.SkillUnits.Skill)

    timestamps()
  end

  @doc false
  def changeset(skill_exam, attrs) do
    skill_exam
    |> cast(attrs, [:skill_id])
    |> validate_required([:skill_id])
  end
end
