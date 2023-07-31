defmodule Bright.DraftSkillUnits.DraftSkillClassUnit do
  @moduledoc """
  下書きのスキルクラスと下書きのスキルユニットの中間テーブルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillPanels.DraftSkillClass
  alias Bright.DraftSkillUnits.DraftSkillUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skill_class_units" do
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :position, :integer

    belongs_to :draft_skill_class, DraftSkillClass
    belongs_to :draft_skill_unit, DraftSkillUnit

    timestamps()
  end

  @doc false
  def changeset(draft_skill_class_unit, attrs) do
    draft_skill_class_unit
    |> cast(attrs, [:draft_skill_class_id, :position])
    |> validate_required([:draft_skill_class_id, :position])
  end
end
