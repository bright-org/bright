defmodule Bright.RecruitsTest do
  use Bright.DataCase

  alias Bright.Recruits

  describe "recruit_inteview" do
    alias Bright.Recruits.Interview

    import Bright.RecruitsFixtures

    @invalid_attrs %{skill_params: nil, status: nil}

    test "list_recruit_inteview/0 returns all recruit_inteview" do
      interview = interview_fixture()
      assert Recruits.list_recruit_inteview() == [interview]
    end

    test "get_interview!/1 returns the interview with given id" do
      interview = interview_fixture()
      assert Recruits.get_interview!(interview.id) == interview
    end

    test "create_interview/1 with valid data creates a interview" do
      valid_attrs = %{skill_params: "some skill_params", status: "some status"}

      assert {:ok, %Interview{} = interview} = Recruits.create_interview(valid_attrs)
      assert interview.skill_params == "some skill_params"
      assert interview.status == "some status"
    end

    test "create_interview/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recruits.create_interview(@invalid_attrs)
    end

    test "update_interview/2 with valid data updates the interview" do
      interview = interview_fixture()
      update_attrs = %{skill_params: "some updated skill_params", status: "some updated status"}

      assert {:ok, %Interview{} = interview} = Recruits.update_interview(interview, update_attrs)
      assert interview.skill_params == "some updated skill_params"
      assert interview.status == "some updated status"
    end

    test "update_interview/2 with invalid data returns error changeset" do
      interview = interview_fixture()
      assert {:error, %Ecto.Changeset{}} = Recruits.update_interview(interview, @invalid_attrs)
      assert interview == Recruits.get_interview!(interview.id)
    end

    test "delete_interview/1 deletes the interview" do
      interview = interview_fixture()
      assert {:ok, %Interview{}} = Recruits.delete_interview(interview)
      assert_raise Ecto.NoResultsError, fn -> Recruits.get_interview!(interview.id) end
    end

    test "change_interview/1 returns a interview changeset" do
      interview = interview_fixture()
      assert %Ecto.Changeset{} = Recruits.change_interview(interview)
    end
  end
end
