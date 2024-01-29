defmodule Bright.Subscriptions.FreeTrialForm do
  @moduledoc """
  フリートライアル申込時のフォームモデル
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Bright.Utils.EmailValidation

  embedded_schema do
    field :user_id, :string
    field :organization_plan, :boolean, default: true
    field :plan_name, :string
    field :company_name, :string
    field :phone_number, :string
    field :email, :string
    field :pic_name, :string
  end

  @doc false
  def changeset(free_trial, attrs) do
    free_trial
    |> cast(attrs, [
      :user_id,
      :plan_name,
      :company_name,
      :phone_number,
      :email,
      :pic_name
    ])
    |> validate_required([:phone_number, :pic_name])
    |> EmailValidation.validate()
    |> validate_organization_required()
  end

  defp validate_organization_required(%{data: %{organization_plan: true}} = changeset) do
    changeset
    |> validate_required([:company_name])
  end

  defp validate_organization_required(changeset), do: changeset
end
