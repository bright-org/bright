defmodule Bright.HistoricalSkillScores.HistoricalSkillClassScore do
  @moduledoc """
  履歴のスキルスコアを扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_class_scores" do
    field :locked_date, :date
    field :level, Ecto.Enum, values: [:beginner, :normal, :skilled], default: :beginner
    field :percentage, :float, default: 0.0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:historical_skill_class, Bright.HistoricalSkillPanels.HistoricalSkillClass)

    timestamps()
  end
end
