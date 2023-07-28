defmodule Bright.HistoricalSkillUnits.HistoricalSkill do
  @moduledoc """
  履歴のスキルを扱うスキーマ。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillUnits.HistoricalSkillCategory

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "historical_skills" do
    field :trace_id, Ecto.UUID
    field :name, :string
    field :position, :integer

    belongs_to :historical_skill_category, HistoricalSkillCategory

    timestamps()
  end
end
