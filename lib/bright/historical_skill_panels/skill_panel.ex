defmodule Bright.HistoricalSkillPanels.SkillPanel do
  @moduledoc """
  スキルパネルを扱うスキーマ。履歴を閲覧する際の参照対象。
  """

  use Ecto.Schema

  alias Bright.HistoricalSkillPanels.HistoricalSkillClass

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_panels" do
    field :name, :string

    has_many :historical_skill_classes, HistoricalSkillClass,
      preload_order: [desc: :locked_date, asc: :class],
      on_replace: :delete

    timestamps()
  end
end
