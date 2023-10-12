defmodule Bright.HistoricalSkillUnits.HistoricalSkill do
  @moduledoc """
  履歴のスキルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Query

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

  def historical_skill_class_query(query \\ __MODULE__, historical_skill_class_id) do
    from q in query,
      join: sc in assoc(q, :historical_skill_category),
      join: su in assoc(sc, :historical_skill_unit),
      join: scu in assoc(su, :historical_skill_class_units),
      where: scu.historical_skill_class_id == ^historical_skill_class_id
  end
end
