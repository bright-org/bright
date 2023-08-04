defmodule Bright.SkillUnits.Skill do
  @moduledoc """
  スキルユニットのスキルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Bright.SkillUnits.SkillCategory

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skills" do
    # TODO: 自動生成を消す
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :name, :string
    field :position, :integer

    belongs_to :skill_category, SkillCategory

    has_many :skill_scores, Bright.SkillScores.SkillScore
    has_many :skill_evidences, Bright.SkillEvidences.SkillEvidence
    has_one :skill_exam, Bright.SkillExams.SkillExam
    has_many :skill_exam_results, Bright.SkillExams.SkillExamResult
    has_one :skill_reference, Bright.SkillReferences.SkillReference

    timestamps()
  end

  @doc false
  def changeset(skill, attrs) do
    skill
    |> cast(attrs, [:name, :position])
    |> cast_assoc(:skill_reference,
      with: &Bright.SkillReferences.SkillReference.changeset_assoc/2
    )
    |> cast_assoc(:skill_exam, with: &Bright.SkillExams.SkillExam.changeset_assoc/2)
    |> validate_required([:name, :position])
  end

  def skill_class_query(query \\ __MODULE__, skill_id) do
    from q in query,
      join: sc in assoc(q, :skill_category),
      join: su in assoc(sc, :skill_unit),
      join: scl in assoc(su, :skill_classes),
      where: scl.id == ^skill_id
  end
end
