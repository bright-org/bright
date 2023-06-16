defmodule Bright.SkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "skill_panels" do
    field :locked_date, :date
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(skill_panel, attrs) do
    skill_panel
    |> cast(attrs, [:locked_date, :name])
    |> validate_required([:name])
  end
end
