defmodule Bright.SkillUnits.SkillClassUnit do
  @moduledoc """
  スキルクラスとスキルユニットの中間テーブルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillUnits.SkillUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_class_units" do
    # TODO: 自動生成を消す
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :position, :integer

    belongs_to :skill_class, SkillClass
    belongs_to :skill_unit, SkillUnit

    timestamps()
  end

  @doc false
  def changeset(skill_category, attrs) do
    skill_category
    |> cast(attrs, [:skill_class_id, :position])
    |> validate_required([:skill_class_id, :position])
  end
end
