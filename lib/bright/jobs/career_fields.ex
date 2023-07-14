defmodule Bright.Jobs.CareerFields do
  @moduledoc """
  キャリアフィールドを扱うスキーマ
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}

  schema "career_fields" do
    field :background_color, :string
    field :button_color, :string
    field :name, :string
    field :position, :integer

    timestamps()
  end

  @doc false
  def changeset(career_fields, attrs) do
    career_fields
    |> cast(attrs, [:name, :background_color, :button_color, :position])
    |> validate_required([:name, :background_color, :button_color, :position])
  end
end
