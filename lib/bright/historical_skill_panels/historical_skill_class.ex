defmodule Bright.HistoricalSkillPanels.HistoricalSkillClass do
  @moduledoc """
  履歴のスキルクラスを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillPanels.SkillPanel
  alias Bright.HistoricalSkillUnits.HistoricalSkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_classes" do
    field :locked_date, :date
    field :trace_id, Ecto.ULID
    field :name, :string
    field :class, :integer

    belongs_to :skill_panel, SkillPanel

    has_many :historical_skill_class_units, HistoricalSkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :historical_skill_units,
      through: [:historical_skill_class_units, :historical_skill_unit]

    has_many :historical_skill_class_scores,
             Bright.HistoricalSkillScores.HistoricalSkillClassScore

    timestamps()
  end
end
