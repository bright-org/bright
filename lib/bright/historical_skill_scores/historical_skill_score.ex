defmodule Bright.HistoricalSkillScores.HistoricalSkillScore do
  @moduledoc """
  履歴のスキル単位のスコアを扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_scores" do
    field :score, Ecto.Enum, values: [:low, :middle, :high]

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:historical_skill, Bright.HistoricalSkillUnits.HistoricalSkill)

    timestamps()
  end
end
