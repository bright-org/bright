defmodule Bright.SkillEvidences.SkillEvidencePost do
  @moduledoc """
  スキルエビデンス投稿を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_evidence_posts" do
    field :content, :string
    field :image_paths, {:array, :string}

    belongs_to :user, Bright.Accounts.User
    belongs_to :skill_evidence, Bright.SkillEvidences.SkillEvidence

    timestamps()
  end

  @doc false
  def changeset(skill_evidence, attrs) do
    skill_evidence
    |> cast(attrs, [:content, :image_paths])
    |> validate_required([:content, :image_paths])
  end
end
