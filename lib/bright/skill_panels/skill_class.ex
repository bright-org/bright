defmodule Bright.SkillPanels.SkillClass do
  @moduledoc """
  スキルクラスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits.SkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_classes" do
    # NOTE: 本来はスキルパネル更新バッチによってのみ生成されるデータのためデフォルト値や自動生成は不要だが、現状では管理機能で作成することができてしまうため便宜上残している
    field :locked_date, :date, default: ~D[2023-07-01]
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}

    field :name, :string
    field :class, :integer

    belongs_to :skill_panel, SkillPanel

    has_many :skill_class_units, SkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_units, through: [:skill_class_units, :skill_unit]
    has_many :skill_class_scores, Bright.SkillScores.SkillClassScore
    has_many :skill_class_score_logs, Bright.SkillScores.SkillClassScoreLog

    timestamps()
  end

  @doc false
  def changeset(skill_class, attrs) do
    skill_class
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
