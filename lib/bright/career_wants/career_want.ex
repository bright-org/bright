defmodule Bright.CareerWants.CareerWant do
  @moduledoc """
  やりたいこと・興味関心があることを扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Bright.CareerWants.CareerWantSkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_wants" do
    field(:name, :string)
    field(:position, :integer)

    has_many :career_want_skill_panels, CareerWantSkillPanel, on_replace: :delete
    has_many :skill_panels, through: [:career_want_skill_panels, :skill_panel]

    timestamps()
  end

  @doc false
  def changeset(career_want, attrs) do
    career_want
    |> cast(attrs, [:name, :position])
    |> cast_assoc(:career_want_skill_panels,
      with: &CareerWantSkillPanel.changeset/2,
      sort_param: :career_want_skill_panel_sort,
      drop_param: :career_want_skill_panel_drop
    )
    |> validate_required([:name, :position])
  end
end
