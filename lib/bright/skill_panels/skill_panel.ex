defmodule Bright.SkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillClass

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :locked_date, :date
    field :name, :string

    has_many :skill_classes, SkillClass, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(skill_panel, attrs) do
    skill_panel
    |> cast(attrs, [:locked_date, :name])
    |> cast_assoc(:skill_classes)
    |> validate_required([:name])
  end
end
