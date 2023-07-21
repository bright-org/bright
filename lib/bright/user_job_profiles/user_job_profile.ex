defmodule Bright.UserJobProfiles.UserJobProfile do
  @moduledoc """
  ユーザーの求職情報を扱うスキーマ
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID

  schema "user_job_profiles" do
    field :availability_date, :date
    field :desired_income, :integer
    field :job_searching, :boolean, default: false
    field :office_working_hours, :integer
    field :office_pref, :integer
    field :office_work, :boolean, default: false
    field :office_work_holidays, :boolean, default: false
    field :remote_working_hours, :integer
    field :remote_work_holidays, :boolean, default: false
    field :remove_work, :boolean, default: false
    field :wish_change_job, :boolean, default: false
    field :wish_employed, :boolean, default: false
    field :wish_freelance, :boolean, default: false
    field :wish_side_job, :boolean, default: false

    belongs_to :user, Bright.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(user_job_profile, attrs) do
    user_job_profile
    |> cast(attrs, [
      :job_searching,
      :wish_employed,
      :wish_change_job,
      :wish_side_job,
      :wish_freelance,
      :availability_date,
      :office_work,
      :office_work_holidays,
      :office_pref,
      :office_working_hours,
      :remove_work,
      :remote_work_holidays,
      :remote_working_hours,
      :desired_income,
      :user_id
    ])
    |> validate_required([
      :job_searching,
      :user_id
    ])
  end
end
