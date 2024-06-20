defmodule Bright.Teams.TeamDefaultSkillPanel do
  @moduledoc """
  チームの初期スキルパネルの設定を管理するスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.SkillPanels.SkillPanel
  alias Bright.Teams.Team

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "team_default_skill_panels" do
    belongs_to :team, Team
    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(team_default_skill_panel, attrs) do
    team_default_skill_panel
    |> cast(attrs, [:team_id, :skill_panel_id])
    |> validate_required([:team_id, :skill_panel_id])
  end
end
