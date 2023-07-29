defmodule Bright.UserJobProfileFactory do
  @moduledoc """
  Factory for Bright.UserJobProfiles.UserJobProfile
  """

  defmacro __using__(_opts) do
    quote do
      def user_job_profile_factory do
        %Bright.UserJobProfiles.UserJobProfile{
          availability_date: ~D[2023-07-20],
          desired_income: 80,
          job_searching: true,
          office_working_hours: "月140h~159h",
          office_pref: "福岡県",
          office_work: true,
          office_work_holidays: true,
          remote_working_hours: "月140h~159h",
          remote_work_holidays: true,
          remote_work: true,
          wish_change_job: true,
          wish_employed: false,
          wish_freelance: true,
          wish_side_job: true,
          user: build(:user)
        }
      end
    end
  end
end
