defmodule Bright.HistoricalSkillScores.HistoricalSkillUnitScore do
  @moduledoc """
  履歴のスキルユニット単位の集計を扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_unit_scores" do
    field :locked_date, :date
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:historical_skill_unit, Bright.HistoricalSkillUnits.HistoricalSkillUnit)

    timestamps()
  end
end
