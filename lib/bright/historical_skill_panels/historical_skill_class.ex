defmodule Bright.HistoricalSkillPanels.HistoricalSkillClass do
  @moduledoc """
  履歴のスキルクラスを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillPanels.SkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_classes" do
    field :locked_date, :date
    field :trace_id, Ecto.UUID
    field :name, :string
    field :class, :integer

    belongs_to :skill_panel, SkillPanel

    timestamps()
  end
end
