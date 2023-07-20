defmodule Bright.UserJobProfiles.UserJobProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_job_profiles" do
    field :availability_date, :naive_datetime
    field :desired_income, :integer
    field :job_searching, :boolean, default: false
    field :office_operating_time, :integer
    field :office_pred, :integer
    field :office_work, :boolean, default: false
    field :office_work_holidays, :boolean, default: false
    field :remote_operating_time, :integer
    field :remote_work_holidays, :boolean, default: false
    field :remove_work, :boolean, default: false
    field :wish_change_job, :boolean, default: false
    field :wish_employed, :boolean, default: false
    field :wish_freelance, :boolean, default: false
    field :wish_side_job, :boolean, default: false
    field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(user_job_profile, attrs) do
    user_job_profile
    |> cast(attrs, [:job_searching, :wish_employed, :wish_change_job, :wish_side_job, :wish_freelance, :availability_date, :office_work, :office_work_holidays, :office_pred, :office_operating_time, :remove_work, :remote_work_holidays, :remote_operating_time, :desired_income])
    |> validate_required([:job_searching, :wish_employed, :wish_change_job, :wish_side_job, :wish_freelance, :availability_date, :office_work, :office_work_holidays, :office_pred, :office_operating_time, :remove_work, :remote_work_holidays, :remote_operating_time, :desired_income])
  end
end
