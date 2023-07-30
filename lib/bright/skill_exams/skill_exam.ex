defmodule Bright.SkillExams.SkillExam do
  @moduledoc """
  スキル試験を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_exams" do
    field :url, :string

    belongs_to(:skill, Bright.SkillUnits.Skill)

    has_many :skill_exam_results, Bright.SkillExams.SkillExamResult

    timestamps()
  end

  @doc false
  def changeset(skill_exam, attrs) do
    skill_exam
    |> cast(attrs, [:skill_id, :url])
    |> validate_required([:skill_id])
  end

  @doc false
  def changeset_assoc(skill_exam, attrs) do
    skill_exam
    |> cast(attrs, [:url])
  end
end
