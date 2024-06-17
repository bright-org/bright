defmodule Bright.Teams.TeamDefaultSkillPanel do
  use Ecto.Schema
  import Ecto.Changeset

  schema "team_default_skill_panels" do
    field :team_id, Ecto.UUID
    field :skill_panel_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(team_default_skill_panel, attrs) do
    team_default_skill_panel
    |> cast(attrs, [:team_id, :skill_panel_id])
    |> validate_required([:team_id, :skill_panel_id])
  end
end
