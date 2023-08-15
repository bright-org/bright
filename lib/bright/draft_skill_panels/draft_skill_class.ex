defmodule Bright.DraftSkillPanels.DraftSkillClass do
  @moduledoc """
  運営下書きのスキルクラスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillPanels.SkillPanel
  alias Bright.DraftSkillUnits.DraftSkillClassUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skill_classes" do
    field :trace_id, Ecto.ULID, autogenerate: {Ecto.ULID, :generate, []}
    field :name, :string
    field :class, :integer

    belongs_to :skill_panel, SkillPanel

    has_many :draft_skill_class_units, DraftSkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :draft_skill_units, through: [:draft_skill_class_units, :draft_skill_unit]

    timestamps()
  end

  @doc false
  def changeset(draft_skill_class, attrs) do
    draft_skill_class
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
