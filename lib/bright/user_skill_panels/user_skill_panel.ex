defmodule Bright.UserSkillPanels.UserSkillPanel do
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.Accounts.User
  alias Bright.SkillPanels.SkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_skill_panels" do
    belongs_to :user, User
    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(user_skill_panel, attrs) do
    user_skill_panel
    |> cast(attrs, [:user_id, :skill_panel_id])
    |> validate_required([:user_id, :skill_panel_id])
  end
end
