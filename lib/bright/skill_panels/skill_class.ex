defmodule Bright.SkillPanels.SkillClass do
  @moduledoc """
  スキルクラスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillPanel
  alias Bright.SkillUnits.SkillUnit

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_classes" do
    field :name, :string

    belongs_to :skill_panel, SkillPanel

    many_to_many :skill_units, SkillUnit,
      join_through: "skill_classes_units",
      unique: true,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_class, attrs) do
    skill_class
    |> cast(attrs, [:name])
    |> put_assoc_skill_units(attrs[:skill_units])
    |> validate_required([:name])
  end

  defp put_assoc_skill_units(changeset, nil), do: changeset

  defp put_assoc_skill_units(changeset, skill_units),
    do: put_assoc(changeset, :skill_units, skill_units)
end
