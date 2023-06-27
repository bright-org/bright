defmodule Bright.SkillUnits.SkillUnit do
  @moduledoc """
  スキルユニットを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillUnits.SkillCategory
  alias Bright.SkillPanels.SkillClass

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_units" do
    field :name, :string

    has_many :skill_categories, SkillCategory, on_replace: :delete

    many_to_many :skill_classes, SkillClass,
      join_through: "skill_classes_units",
      unique: true,
      on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_unit, attrs) do
    skill_unit
    |> cast(attrs, [:name])
    |> cast_assoc(:skill_categories)
    |> put_assoc_skill_classes(attrs[:skill_classes])
    |> validate_required([:name])
  end

  defp put_assoc_skill_classes(changeset, nil), do: changeset

  defp put_assoc_skill_classes(changeset, skill_classes),
    do: put_assoc(changeset, :skill_classes, skill_classes)
end
