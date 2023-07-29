defmodule Bright.DraftSkillPanels.DraftSkillClass do
  @moduledoc """
  下書きのスキルクラスを扱うスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.DraftSkillPanels.SkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "draft_skill_classes" do
    field :trace_id, Ecto.UUID, autogenerate: {Ecto.UUID, :generate, []}
    field :name, :string
    field :class, :integer

    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(draft_skill_class, attrs) do
    draft_skill_class
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
