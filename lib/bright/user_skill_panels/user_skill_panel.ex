defmodule Bright.UserSkillPanels.UserSkillPanel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_skill_panels" do
    field :user_id, Ecto.UUID
    field :skill_panel_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(user_skill_panel, attrs) do
    user_skill_panel
    |> cast(attrs, [:user_id, :skill_panel_id])
    |> validate_required([:user_id, :skill_panel_id])
  end
end
