defmodule Bright.Recruits.Interview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recruit_inteview" do
    field :comment, :string
    field :skill_params, :string
    field :status, :string
    field :interview_user_id, :id
    field :recruiter_id, :id

    timestamps()
  end

  @doc false
  def changeset(interview, attrs) do
    interview
    |> cast(attrs, [:skill_params, :status, :string])
    |> validate_required([:skill_params, :status])
  end
end
