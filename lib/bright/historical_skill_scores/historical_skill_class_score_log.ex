defmodule Bright.HistoricalSkillScores.HistoricalSkillClassScoreLog do
  @moduledoc """
  履歴のスキルスコアログを扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_class_score_logs" do
    field :date, :date
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:historical_skill_class, Bright.HistoricalSkillPanels.HistoricalSkillClass)

    timestamps()
  end
end
