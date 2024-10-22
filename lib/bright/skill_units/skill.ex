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
    # NOTE: 本来はスキルパネル更新バッチによってのみ生成されるデータのため自動生成は不要だが、現状では管理機能で作成することができてしまうため便宜上残している
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}

    field :name, :string
    field :position, :integer

    belongs_to :skill_category, SkillCategory

    has_many :skill_scores, Bright.SkillScores.SkillScore, on_delete: :delete_all
    has_many :skill_evidences, Bright.SkillEvidences.SkillEvidence
    has_one :skill_exam, Bright.SkillExams.SkillExam, on_delete: :delete_all
    has_one :skill_reference, Bright.SkillReferences.SkillReference, on_delete: :delete_all

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

  def skill_class_query(query \\ __MODULE__, skill_class_id) do
    from q in query,
      join: sc in assoc(q, :skill_category),
      join: su in assoc(sc, :skill_unit),
      join: scu in assoc(su, :skill_class_units),
      where: scu.skill_class_id == ^skill_class_id
  end
end
