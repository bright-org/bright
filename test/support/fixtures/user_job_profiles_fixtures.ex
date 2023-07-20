defmodule Bright.UserJobProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.UserJobProfiles` context.
  """

  @doc """
  Generate a user_job_profile.
  """
  def user_job_profile_fixture(attrs \\ %{}) do
    {:ok, user_job_profile} =
      attrs
      |> Enum.into(%{
        availability_date: ~N[2023-07-19 15:19:00],
        desired_income: 42,
        job_searching: true,
        office_operating_time: 42,
        office_pred: 42,
        office_work: true,
        office_work_holidays: true,
        remote_operating_time: 42,
        remote_work_holidays: true,
        remove_work: true,
        wish_change_job: true,
        wish_employed: true,
        wish_freelance: true,
        wish_side_job: true
      })
      |> Bright.UserJobProfiles.create_user_job_profile()

    user_job_profile
  end
end
