defmodule Bright.HistoricalSkillUnits.HistoricalSkillCategory do
  @moduledoc """
  履歴のスキルカテゴリを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillUnits.HistoricalSkillUnit
  alias Bright.HistoricalSkillUnits.HistoricalSkill

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skill_categories" do
    field :trace_id, Ecto.ULID
    field :name, :string
    field :position, :integer

    belongs_to :historical_skill_unit, HistoricalSkillUnit

    has_many :historical_skills, HistoricalSkill,
      preload_order: [asc: :position],
      on_replace: :delete

    timestamps()
  end
end
