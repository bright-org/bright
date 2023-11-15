defmodule Bright.SkillScores.SkillClassScore do
  @moduledoc """
  スキルクラス単位の集計を扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_class_scores" do
    # NOTE: level
    # スキルクラス単位のレベルを表します。
    # 役職系の単語は誤解を招くため避けて命名しています。NG例: junior, middle, senior
    field :level, Ecto.Enum, values: [:beginner, :normal, :skilled], default: :beginner
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill_class, Bright.SkillPanels.SkillClass)

    timestamps()
  end

  @doc false
  def changeset(skill_class_score, attrs) do
    skill_class_score
    |> cast(attrs, [:level, :percentage])
    |> validate_required([:level, :percentage])
  end

  def user_query(user) do
    user_id_query(user.id)
  end

  def user_id_query(user_id) do
    from(q in __MODULE__, where: q.user_id == ^user_id)
  end

  def user_ids_query(user_ids) do
    from(q in __MODULE__, where: q.user_id in ^user_ids)
  end
end
