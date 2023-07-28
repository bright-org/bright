defmodule Bright.HistoricalSkillUnits.HistoricalSkillClassUnit do
  @moduledoc """
  履歴のスキルクラスと履歴のスキルユニットの中間テーブルを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillPanels.HistoricalSkillClass
  alias Bright.HistoricalSkillUnits.HistoricalSkillUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_class_units" do
    field :trace_id, Ecto.UUID
    field :position, :integer

    belongs_to :historical_skill_class, HistoricalSkillClass
    belongs_to :historical_skill_unit, HistoricalSkillUnit

    timestamps()
  end
end
