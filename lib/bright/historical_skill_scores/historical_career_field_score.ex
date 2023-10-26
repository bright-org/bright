defmodule Bright.HistoricalSkillScores.HistoricalCareerFieldScore do
  @moduledoc """
  履歴のキャリアフィールド単位の集計を扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_career_field_scores" do
    field :locked_date, :date
    field :percentage, :float, default: 0.0
    field :high_skills_count, :integer, default: 0

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:career_field, Bright.CareerFields.CareerField)

    timestamps()
  end
end
