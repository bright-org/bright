defmodule Bright.RecruitsTest do
  use Bright.DataCase

  alias Bright.Recruits
  alias Bright.Recruits.Interview
  alias Bright.Recruits.InterviewMember
  import Bright.Factory

  describe "interview" do
    setup do
      recruiter = insert(:user)
      candidates = insert(:user)

      interview =
        insert(:interview, recruiter_user_id: recruiter.id, candidates_user_id: candidates.id)

      %{recruiter: recruiter, candidates: candidates, interview: interview}
    end

    @invalid_attrs %{skill_params: nil, status: nil}

    test "list_interview/0 returns all interview", %{interview: interview} do
      assert Recruits.list_interview() == [interview]
    end

    test "get_interview!/1 returns the interview with given id", %{interview: interview} do
      assert Recruits.get_interview!(interview.id) == interview
    end

    test "create_interview/1 with valid data creates a interview", %{
      recruiter: recruiter,
      candidates: candidates
    } do
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

    test "update_interview/2 with valid data updates the interview", %{interview: interview} do
      update_attrs = %{skill_params: "some updated skill_params", status: :consume_interview}

      assert {:ok, %Interview{} = interview} = Recruits.update_interview(interview, update_attrs)
      assert interview.skill_params == "some updated skill_params"
      assert interview.status == :consume_interview
    end

    test "update_interview/2 with invalid data returns error changeset", %{interview: interview} do
      assert {:error, %Ecto.Changeset{}} = Recruits.update_interview(interview, @invalid_attrs)
      assert interview == Recruits.get_interview!(interview.id)
    end

    test "delete_interview/1 deletes the interview", %{interview: interview} do
      assert {:ok, %Interview{}} = Recruits.delete_interview(interview)
      assert_raise Ecto.NoResultsError, fn -> Recruits.get_interview!(interview.id) end
    end

    test "change_interview/1 returns a interview changeset", %{interview: interview} do
      assert %Ecto.Changeset{} = Recruits.change_interview(interview)
    end
  end

  describe "recruit_interview_members" do
    setup do
      recruiter = insert(:user)
      member = insert(:user)
      candidates = insert(:user)

      interview =
        insert(:interview, recruiter_user_id: recruiter.id, candidates_user_id: candidates.id)

      interview_member = insert(:interview_member, user_id: member.id, interview_id: interview.id)

      %{
        recruiter: recruiter,
        member: member,
        candidates: candidates,
        interview: interview,
        interview_member: interview_member
      }
    end

    test "list_interview_members/1 returns user's all interview_members", %{
      interview_member: %{id: interview_member_id},
      member: %{id: member_id}
    } do
      insert(:interview,
        interview_members: [build(:interview_member, user_id: insert(:user).id)],
        recruiter_user_id: insert(:user).id,
        candidates_user_id: insert(:user).id
      )

      assert [%{user_id: ^member_id, id: ^interview_member_id}] =
               Recruits.list_interview_members(member_id)
    end

    test "list_interview_members/1 returns not awnserd all interview_members", %{
      interview_member: %{id: interview_member_id},
      member: %{id: member_id}
    } do
      # answerd_interview_member
      insert(:interview,
        interview_members: [build(:interview_member, user_id: member_id, decision: :wants)],
        recruiter_user_id: insert(:user).id,
        candidates_user_id: insert(:user).id
      )

      # dismiss interview
      insert(:interview,
        interview_members: [build(:interview_member, user_id: member_id)],
        recruiter_user_id: insert(:user).id,
        candidates_user_id: insert(:user).id,
        status: :dismiss_interview
      )

      assert [%{user_id: ^member_id, id: ^interview_member_id}] =
               Recruits.list_interview_members(member_id, :not_answered)
    end

    test "get_interview_member!/2 returns the interview member with given id with user_id", %{
      interview_member: %{id: interview_member_id},
      member: %{id: member_id}
    } do
      assert %{id: ^interview_member_id, user_id: ^member_id} =
               Recruits.get_interview_member!(interview_member_id, member_id)
    end

    test "get_interview_member!/2 returns 404 with given id with invalid user_id", %{
      interview_member: interview_member,
      recruiter: recruiter
    } do
      assert_raise Ecto.NoResultsError, fn ->
        assert Recruits.get_interview_member!(interview_member.id, recruiter.id)
      end
    end

    test "update_interview_member/2 with valid data updates the interview", %{
      interview_member: interview_member
    } do
      update_attrs = %{decision: :wants}

      assert {:ok, %InterviewMember{} = interview_member} =
               Recruits.update_interview_member(interview_member, update_attrs)

      assert interview_member.decision == :wants
    end

    test "update_interview/2 with invalid data returns error changeset", %{
      interview_member: interview_member,
      member: member
    } do
      assert {:error, %Ecto.Changeset{}} =
               Recruits.update_interview_member(interview_member, %{decision: :invalid})

      assert %{decision: :not_answered} =
               Recruits.get_interview_member!(interview_member.id, member.id)
    end

    test "interview_no_answer?/1 check Respondent", %{
      interview: interview
    } do
      assert Recruits.interview_no_answer?(interview.id) == true
    end
  end
end
