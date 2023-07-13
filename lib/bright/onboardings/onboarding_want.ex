defmodule Bright.Onboardings.OnboardingWant do
  @moduledoc """
  オンボーディングの「やりたいこと・興味関心があること」を扱うスキーマ。
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}

  schema "onboarding_wants" do
    field :name, :string
    field :position, :integer

    timestamps()
  end

  @doc false
  def changeset(onboarding_want, attrs) do
    onboarding_want
    |> cast(attrs, [:name, :position])
    |> validate_required([:name, :position])
  end
end
