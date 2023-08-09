defmodule Bright.CareerFields.CareerFieldSkillPanel do
  @moduledoc """
  キャリアフィールド、スキルパネルの中間テーブル
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_field_skill_panels" do
    belongs_to :career_field, Bright.CareerFields.CareerField
    belongs_to :skill_panel, Bright.SkillPanels.SkillPanel

    timestamps()
  end

  @doc false
  def changeset(user_skill_panel, attrs) do
    user_skill_panel
    |> cast(attrs, [:career_field_id, :skill_panel_id])
    |> validate_required([:career_field_id])
  end
end
