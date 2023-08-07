defmodule Bright.SkillScores.SkillScore do
  @moduledoc """
  スキル単位のスコアを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_scores" do
    field :score, Ecto.Enum, values: [:low, :middle, :high]

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill, Bright.SkillUnits.Skill)

    timestamps()
  end

  @doc false
  def changeset(skill_score, attrs) do
    skill_score
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end

  def user_query(user), do: user_id_query(user.id)

  def user_id_query(user_id) do
    from q in __MODULE__,
      where: q.user_id == ^user_id
  end
end
