defmodule Bright.CareerGroups.CareerGroupCareerField do
  @moduledoc """
  キャリアグループとキャリアフィールドを関連づけるスキーマ。
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "career_group_career_fields" do
    belongs_to :career_group, Bright.CareerGroups.CareerGroup
    belongs_to :career_field, Bright.CareerFields.CareerField

    timestamps()
  end

  @doc false
  def changeset(career_group_career_field, attrs) do
    career_group_career_field
    |> cast(attrs, [:career_group_id, :career_field_id])
  end
end
