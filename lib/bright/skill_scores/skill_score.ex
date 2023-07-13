defmodule Bright.SkillScores.SkillScore do
  @moduledoc """
  スキルスコアを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_scores" do
    # NOTE: level
    # スキルクラス単位のレベルを表します。
    # 役職系の単語は誤解を招くため避けて命名しています。NG例: junior, middle, senior
    field :level, Ecto.Enum, values: [:beginner, :normal, :skilled], default: :beginner
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill_class, Bright.SkillPanels.SkillClass)

    has_many(:skill_score_items, Bright.SkillScores.SkillScoreItem)

    timestamps()
  end

  @doc false
  def changeset(skill_score, attrs) do
    skill_score
    |> cast(attrs, [:user_id, :skill_class_id, :level, :percentage])
    |> validate_required([:user_id, :skill_class_id, :level, :percentage])
  end
end
