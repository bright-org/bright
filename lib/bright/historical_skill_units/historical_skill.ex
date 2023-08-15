defmodule Bright.HistoricalSkillUnits.HistoricalSkill do
  @moduledoc """
  履歴のスキルを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillUnits.HistoricalSkillCategory

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skills" do
    field :trace_id, Ecto.ULID
    field :name, :string
    field :position, :integer

    belongs_to :historical_skill_category, HistoricalSkillCategory

    has_many :historical_skill_scores, Bright.HistoricalSkillScores.HistoricalSkillScore

    timestamps()
  end
end
