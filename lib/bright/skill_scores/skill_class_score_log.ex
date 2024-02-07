defmodule Bright.SkillScores.SkillClassScoreLog do
  @moduledoc """
  スキルクラス単位の習得率変遷を扱うスキーマ。
  """

  use Ecto.Schema

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "skill_class_score_logs" do
    field :date, :date
    field :percentage, :float

    belongs_to(:user, Bright.Accounts.User)
    belongs_to(:skill_class, Bright.SkillPanels.SkillClass)

    timestamps()
  end
end
