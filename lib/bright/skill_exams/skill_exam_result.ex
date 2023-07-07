defmodule Bright.SkillExams.SkillExamResult do
  @moduledoc """
  スキル試験の結果を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_exam_results" do
    # 要件が決まっていませんので仮です。
    # 完了状態は必要のため定義しています。スキルパネルの表示判定に使用します。
    # ↑コメントは本実装後に削除してください。
    field :progress, Ecto.Enum, values: [wip: 10, done: 20]

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill, Bright.SkillUnits.Skill)
    belongs_to(:skill_exam, Bright.SkillExams.SkillExam)

    timestamps()
  end

  @doc false
  def changeset(skill_exam_result, attrs) do
    skill_exam_result
    |> cast(attrs, [:user_id, :skill_id, :skill_exam_id, :progress])
    |> validate_required([:user_id, :skill_id, :skill_exam_id, :progress])
  end
end
