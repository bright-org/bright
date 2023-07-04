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
    field :name, :string
    field :rank, :integer

    belongs_to :skill_panel, SkillPanel

    has_many :skill_class_units, SkillClassUnit,
      preload_order: [asc: :position],
      on_replace: :delete

    has_many :skill_units, through: [:skill_class_units, :skill_unit]

    timestamps()
  end

  @doc false
  def changeset(skill_class, attrs) do
    skill_class
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
