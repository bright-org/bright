defmodule Bright.RecruitsTest do
  use Bright.DataCase

  alias Bright.Recruits
  alias Bright.Recruits.Interview
  import Bright.Factory

  describe "recruit_interview" do
    @invalid_attrs %{skill_params: nil, status: nil}

    test "list_recruit_interview/0 returns all recruit_interview" do
      interview = insert(:interview)
      assert Recruits.list_interview() == [interview]
    end

    test "get_interview!/1 returns the interview with given id" do
      interview = insert(:interview)
      assert Recruits.get_interview!(interview.id) == interview
    end

    test "create_interview/1 with valid data creates a interview" do
      recruiter = insert(:user)
      candidates = insert(:user)

      valid_attrs = %{
        skill_params: "some skill_params",
        status: :waiting_decision,
        recruiter_user_id: recruiter.id,
        candidates_user_id: candidates.id
      }

      assert {:ok, %Interview{} = interview} = Recruits.create_interview(valid_attrs)
      assert interview.skill_params == "some skill_params"
      assert interview.status == :waiting_decision
    end

    test "create_interview/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recruits.create_interview(@invalid_attrs)
    end

    test "update_interview/2 with valid data updates the interview" do
      interview = insert(:interview, recruiter_user_id: insert(:user).id, candidates_user_id: insert(:user).id)
      update_attrs = %{skill_params: "some updated skill_params", status: :consume_interview,}

      assert {:ok, %Interview{} = interview} = Recruits.update_interview(interview, update_attrs)
      assert interview.skill_params == "some updated skill_params"
      assert interview.status == :consume_interview
    end

    test "update_interview/2 with invalid data returns error changeset" do
      interview = insert(:interview)
      assert {:error, %Ecto.Changeset{}} = Recruits.update_interview(interview, @invalid_attrs)
      assert interview == Recruits.get_interview!(interview.id)
    end

    test "delete_interview/1 deletes the interview" do
      interview = insert(:interview)
      assert {:ok, %Interview{}} = Recruits.delete_interview(interview)
      assert_raise Ecto.NoResultsError, fn -> Recruits.get_interview!(interview.id) end
    end

    test "change_interview/1 returns a interview changeset" do
      interview = insert(:interview)
      assert %Ecto.Changeset{} = Recruits.change_interview(interview)
    end
  end
end
