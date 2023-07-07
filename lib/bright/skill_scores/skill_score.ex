defmodule Bright.SkillScores.SkillScore do
  @moduledoc """
  スキルスコアを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_scores" do
    field :level, Ecto.Enum, values: [junior: 10, middle: 20, senior: 30], default: :junior
    field :percentage, :integer, default: 0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill_class, Bright.SkillPanels.SkillClass)

    timestamps()
  end

  @doc false
  def changeset(skill_score, attrs) do
    skill_score
    |> cast(attrs, [:user_id, :skill_class_id, :level, :percentage])
    |> validate_required([:user_id, :skill_class_id, :level, :percentage])
  end
end
