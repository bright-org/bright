defmodule Bright.HistoricalSkillUnits.HistoricalSkillUnit do
  @moduledoc """
  履歴のスキルユニットを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillUnits.HistoricalSkillCategory
  alias Bright.HistoricalSkillUnits.HistoricalSkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_units" do
    field :locked_date, :date
    field :trace_id, Ecto.ULID
    field :name, :string

    has_many :historical_skill_categories, HistoricalSkillCategory,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :historical_skill_class_units, HistoricalSkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :historical_skill_classes,
      through: [:historical_skill_class_units, :historical_skill_class]

    has_many :historical_skill_unit_scores, Bright.HistoricalSkillScores.HistoricalSkillUnitScore

    timestamps()
  end
end
