defmodule Bright.SkillEvidences.SkillEvidence do
  @moduledoc """
  スキルエビデンスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_evidences" do
    field :progress, Ecto.Enum, values: [:wip, :help, :done]

    belongs_to :user, Bright.Accounts.User
    belongs_to :skill, Bright.SkillUnits.Skill

    has_many :skill_evidence_posts, Bright.SkillEvidences.SkillEvidencePost,
      preload_order: [asc: :inserted_at]

    timestamps()
  end

  @doc false
  def changeset(skill_evidence, attrs) do
    skill_evidence
    |> cast(attrs, [:user_id, :skill_id, :progress])
    |> validate_required([:user_id, :skill_id, :progress])
  end
end
