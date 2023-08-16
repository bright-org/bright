defmodule Bright.Onboardings.UserOnboarding do
  @moduledoc """
  ユーザーのオンボーディング結果を扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Accounts.User
  alias Bright.SkillPanels.SkillPanel

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_onboardings" do
    field :completed_at, :naive_datetime
    belongs_to :user, User
    # 集計用でシステムで直接は使用しない
    belongs_to :skill_panel, SkillPanel

    timestamps()
  end

  @doc false
  def changeset(user_onboardings, attrs) do
    user_onboardings
    |> cast(attrs, [:user_id, :completed_at, :skill_panel_id])
    |> validate_required([:completed_at])
  end
end
