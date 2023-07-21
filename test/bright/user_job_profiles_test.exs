defmodule Bright.UserJobProfilesTest do
  use Bright.DataCase

  alias Bright.UserJobProfiles

  import Bright.Factory

  describe "user_job_profiles" do
    alias Bright.UserJobProfiles.UserJobProfile

    @invalid_attrs %{
      availability_date: nil,
      desired_income: nil,
      job_searching: nil,
      office_operating_time: nil,
      office_pred: nil,
      office_work: nil,
      office_work_holidays: nil,
      remote_operating_time: nil,
      remote_work_holidays: nil,
      remove_work: nil,
      user_id: nil,
      wish_change_job: nil,
      wish_employed: nil,
      wish_freelance: nil,
      wish_side_job: nil
    }

    test "list_user_job_profiles/0 returns all user_job_profiles" do
      %UserJobProfile{id: id} = insert(:user_job_profile)

      assert [
               %UserJobProfile{id: ^id}
             ] = UserJobProfiles.list_user_job_profiles()
    end

    test "get_user_job_profile!/1 returns the user_job_profile with given id" do
      %UserJobProfile{id: id} = insert(:user_job_profile)

      assert %UserJobProfile{
               id: ^id
             } = UserJobProfiles.get_user_job_profile!(id)
    end

    test "create_user_job_profile/1 with valid data creates a user_job_profile" do
      user = insert(:user)

      valid_attrs = %{
        availability_date: ~N[2023-07-20 00:00:00],
        desired_income: 80,
        job_searching: true,
        office_operating_time: 3,
        office_pred: 42,
        office_work: true,
        office_work_holidays: true,
        remote_operating_time: 3,
        remote_work_holidays: true,
        remove_work: true,
        wish_change_job: true,
        wish_employed: false,
        wish_freelance: true,
        wish_side_job: true,
        user_id: user.id
      }

      assert {:ok, %UserJobProfile{} = user_job_profile} =
               UserJobProfiles.create_user_job_profile(valid_attrs)

      assert user_job_profile.availability_date == ~N[2023-07-20 00:00:00]
      assert user_job_profile.desired_income == 80
      assert user_job_profile.job_searching == true
      assert user_job_profile.office_operating_time == 3
      assert user_job_profile.office_pred == 42
      assert user_job_profile.office_work == true
      assert user_job_profile.office_work_holidays == true
      assert user_job_profile.remote_operating_time == 3
      assert user_job_profile.remote_work_holidays == true
      assert user_job_profile.remove_work == true
      assert user_job_profile.wish_change_job == true
      assert user_job_profile.wish_employed == false
      assert user_job_profile.wish_freelance == true
      assert user_job_profile.wish_side_job == true
    end

    test "create_user_job_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserJobProfiles.create_user_job_profile(@invalid_attrs)
    end

    test "update_user_job_profile/2 with valid data updates the user_job_profile" do
      user_job_profile = insert(:user_job_profile)

      update_attrs = %{
        availability_date: ~N[2023-07-25 00:00:00],
        desired_income: 43,
        job_searching: false,
        office_operating_time: 2,
        office_pred: 18,
        office_work: false,
        office_work_holidays: false,
        remote_operating_time: 2,
        remote_work_holidays: false,
        remove_work: false,
        wish_change_job: false,
        wish_employed: false,
        wish_freelance: false,
        wish_side_job: false
      }

      assert {:ok, %UserJobProfile{} = user_job_profile} =
               UserJobProfiles.update_user_job_profile(user_job_profile, update_attrs)

      assert user_job_profile.availability_date == ~N[2023-07-25 00:00:00]
      assert user_job_profile.desired_income == 43
      assert user_job_profile.job_searching == false
      assert user_job_profile.office_operating_time == 2
      assert user_job_profile.office_pred == 18
      assert user_job_profile.office_work == false
      assert user_job_profile.office_work_holidays == false
      assert user_job_profile.remote_operating_time == 2
      assert user_job_profile.remote_work_holidays == false
      assert user_job_profile.remove_work == false
      assert user_job_profile.wish_change_job == false
      assert user_job_profile.wish_employed == false
      assert user_job_profile.wish_freelance == false
      assert user_job_profile.wish_side_job == false
    end

    test "update_user_job_profile/2 with invalid data returns error changeset" do
      %UserJobProfile{updated_at: updated_at} = user_job_profile = insert(:user_job_profile)

      assert {:error, %Ecto.Changeset{}} =
               UserJobProfiles.update_user_job_profile(user_job_profile, @invalid_attrs)

      assert %UserJobProfile{updated_at: ^updated_at} =
               UserJobProfiles.get_user_job_profile!(user_job_profile.id)
    end

    test "delete_user_job_profile/1 deletes the user_job_profile" do
      user_job_profile = insert(:user_job_profile)
      assert {:ok, %UserJobProfile{}} = UserJobProfiles.delete_user_job_profile(user_job_profile)

      assert_raise Ecto.NoResultsError, fn ->
        UserJobProfiles.get_user_job_profile!(user_job_profile.id)
      end
    end

    test "change_user_job_profile/1 returns a user_job_profile changeset" do
      user_job_profile = insert(:user_job_profile)
      assert %Ecto.Changeset{} = UserJobProfiles.change_user_job_profile(user_job_profile)
    end
  end
end
