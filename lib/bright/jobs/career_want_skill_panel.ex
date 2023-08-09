defmodule Bright.Jobs.CareerWantSkillPanel do
  @moduledoc """
  やりたいこととスキルパネルを関連づけるスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_want_skill_panels" do
    belongs_to :career_want, Bright.Jobs.CareerWant
    belongs_to :skill_panel, Bright.SkillPanels.SkillPanel

    timestamps()
  end

  @doc false
  def changeset(career_want_skill_panel, attrs) do
    career_want_skill_panel
    |> cast(attrs, [:career_want_id, :skill_panel_id])
    |> validate_required([:career_want_id, :skill_panel_id])
  end
end
