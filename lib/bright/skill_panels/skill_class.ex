defmodule Bright.SkillPanels.SkillClass do
  @moduledoc """
  スキルクラスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.SkillPanels.SkillPanel

  schema "skill_classes" do
    field :name, :string

    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(skill_class, attrs) do
    skill_class
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
