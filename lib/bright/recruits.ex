defmodule Bright.Recruits do
  @moduledoc """
  The Recruits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo
  alias Bright.Recruits.InterviewMember
  alias Bright.Recruits.Interview
  alias Bright.Accounts.UserNotifier

  @doc """
  Returns the list of recruit_interview.

  ## Examples

      iex> list_interview()
      [%Interview{}, ...]

  """
  def list_interview do
    Repo.all(Interview)
  end

  def list_interview(user_id) do
    Interview
    |> where([i], i.recruiter_user_id == ^user_id)
    |> Repo.all()
  end

  def list_interview(user_id, :not_complete) do
    Interview
    |> where(
      [i],
      i.recruiter_user_id == ^user_id and
        i.status in [:waiting_decision, :consume_interview, :ongoing_interview]
    )
    |> preload(candidates_user: :user_profile)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def list_interview(user_id, status) do
    Interview
    |> where(
      [i],
      i.recruiter_user_id == ^user_id and i.status == ^status
    )
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single interview.

  Raises `Ecto.NoResultsError` if the Interview does not exist.

  ## Examples

      iex> get_interview!(123)
      %Interview{}

      iex> get_interview!(456)
      ** (Ecto.NoResultsError)

  """
  def get_interview!(id), do: Repo.get!(Interview, id)

  def get_interview_with_member_users!(id, user_id) do
    Interview
    |> where([i], i.recruiter_user_id == ^user_id)
    |> preload(interview_members: [user: :user_profile])
    |> Repo.get!(id)
  end

  @doc """
  Creates a interview.

  ## Examples

      iex> create_interview(%{field: value})
      {:ok, %Interview{}}

      iex> create_interview(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_interview(attrs \\ %{}) do
    %Interview{}
    |> Interview.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a interview.

  ## Examples

      iex> update_interview(interview, %{field: new_value})
      {:ok, %Interview{}}

      iex> update_interview(interview, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_interview(%Interview{} = interview, attrs) do
    interview
    |> Interview.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a interview.

  ## Examples

      iex> delete_interview(interview)
      {:ok, %Interview{}}

      iex> delete_interview(interview)
      {:error, %Ecto.Changeset{}}

  """
  def delete_interview(%Interview{} = interview) do
    Repo.delete(interview)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking interview changes.

  ## Examples

      iex> change_interview(interview)
      %Ecto.Changeset{data: %Interview{}}

  """
  def change_interview(%Interview{} = interview, attrs \\ %{}) do
    Interview.changeset(interview, attrs)
  end

  def list_interview_members(user_id) do
    InterviewMember
    |> where([m], m.user_id == ^user_id)
    |> preload(:interview)
    |> Repo.all()
  end

  def list_interview_members(user_id, decision) do
    from(m in InterviewMember,
      join: i in Interview,
      on: i.id == m.interview_id and i.status in [:waiting_decision, :consume_interview],
      where: m.user_id == ^user_id and m.decision == ^decision,
      order_by: [desc: :updated_at],
      preload: :interview
    )
    |> Repo.all()
  end

  def get_interview_member!(id, user_id) do
    InterviewMember
    |> where([m], m.user_id == ^user_id)
    |> preload(:interview)
    |> Repo.get!(id)
  end

  def update_interview_member(%InterviewMember{} = interview_member, attrs) do
    interview_member
    |> InterviewMember.changeset(attrs)
    |> Repo.update()
  end

  def interview_no_answer?(interview_id) do
    ans =
      InterviewMember
      |> where([m], m.interview_id == ^interview_id)
      |> Repo.all()

    case ans do
      [] -> false
      _ -> Enum.all?(ans, &(&1.decision == :not_answered))
    end
  end

  def deliver_acceptance_email_instructions(
        from_user,
        to_user,
        interview_member,
        acceptance_interview_url_fun
      )
      when is_function(acceptance_interview_url_fun, 1) do
    if !Bright.Utils.Env.prod?() or Application.get_env(:bright, :dev_routes) do
      :ets.insert(
        :token,
        {"acceptance", to_user.email, to_user.name,
         acceptance_interview_url_fun.(interview_member.id)}
      )
    end

    UserNotifier.deliver_acceptance_interview_instructions(
      from_user,
      to_user,
      acceptance_interview_url_fun.(interview_member.id)
    )
  end

  def send_interview_start_notification_mails(interview_id) do
    interview =
      Interview
      |> preload([:candidates_user, :recruiter_user])
      |> Repo.get!(interview_id)

    UserNotifier.deliver_start_interview_to_candidates_user(
      interview.recruiter_user,
      interview.candidates_user
    )

    UserNotifier.deliver_start_interview_to_recruiter(
      interview.recruiter_user,
      interview.candidates_user
    )
  end

  def send_interview_cancel_notification_mails(interview_id) do
    interview =
      Interview
      |> preload([:candidates_user, :recruiter_user])
      |> Repo.get!(interview_id)

    UserNotifier.deliver_cancel_interview_to_candidates_user(
      interview.recruiter_user,
      interview.candidates_user
    )
  end

  alias Bright.Recruits.Coordination
  alias Bright.Recruits.CoordinationMember

  @doc """
  Returns the list of coordination.

  ## Examples

      iex> list_coordination()
      [%Coordination{}, ...]

  """

  def list_coordination do
    Repo.all(Coordination)
  end

  def list_coordination(user_id) do
    Coordination
    |> where([i], i.recruiter_user_id == ^user_id)
    |> Repo.all()
  end

  def list_coordination(user_id, :not_complete) do
    Coordination
    |> where(
      [i],
      i.recruiter_user_id == ^user_id and
        i.status in [:waiting_recruit_decision, :consume_coordination, :ongoing_coordination]
    )
    |> preload(candidates_user: :user_profile)
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  def list_coordination(user_id, status) do
    Coordination
    |> where(
      [i],
      i.recruiter_user_id == ^user_id and i.status == ^status
    )
    |> order_by(desc: :updated_at)
    |> Repo.all()
  end

  @doc """
  Gets a single Coordination.

  Raises `Ecto.NoResultsError` if the Coordination does not exist.

  ## Examples

      iex> get_coordination!(123)
      %Coordination{}

      iex> get_coordination!(456)
      ** (Ecto.NoResultsError)

  """
  def get_coordination!(id), do: Repo.get!(Coordination, id)

  def get_coordination_with_member_users!(id, user_id) do
    Coordination
    |> where([i], i.recruiter_user_id == ^user_id)
    |> preload(coordination_members: [user: :user_profile])
    |> Repo.get!(id)
  end

  @doc """
  Creates a Coordination.

  ## Examples

      iex> create_coordination(%{field: value})
      {:ok, %Coordination{}}

      iex> create_Coordination(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_coordination(attrs \\ %{}) do
    %Coordination{}
    |> Coordination.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a coordination.

  ## Examples

      iex> update_Coordination(coordination, %{field: new_value})
      {:ok, %Coordination{}}

      iex> update_coordination(coordination, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_coordination(%Coordination{} = coordination, attrs) do
    coordination
    |> Coordination.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a coordination.

  ## Examples

      iex> delete_coordination(coordination)
      {:ok, %Coordination{}}

      iex> delete_ccoordination(coordination)
      {:error, %Ecto.Changeset{}}

  """
  def delete_coordination(%Coordination{} = coordination) do
    Repo.delete(coordination)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking coordination changes.

  ## Examples

      iex> change_oordination(coordination)
      %Ecto.Changeset{data: %Coordination{}}

  """
  def change_coordination(%Coordination{} = coordination, attrs \\ %{}) do
    Coordination.changeset(coordination, attrs)
  end

  def list_coordination_members(user_id) do
    CoordinationMember
    |> where([m], m.user_id == ^user_id)
    |> preload(:coordination)
    |> Repo.all()
  end

  def list_coordination_members(user_id, decision) do
    from(m in CoordinationMember,
      join: i in Coordination,
      on:
        i.id == m.coordination_id and
          i.status in [:waiting_recruit_decision, :consume_coordination],
      where: m.user_id == ^user_id and m.decision == ^decision,
      order_by: [desc: :updated_at],
      preload: :coordination
    )
    |> Repo.all()
  end

  def get_coordination_member!(id, user_id) do
    CoordinationMember
    |> where([m], m.user_id == ^user_id)
    |> preload(:coordination)
    |> Repo.get!(id)
  end

  def update_coordination_member(%CoordinationMember{} = coordination_member, attrs) do
    coordination_member
    |> CoordinationMember.changeset(attrs)
    |> Repo.update()
  end

  def coordination_no_answer?(coordination_id) do
    ans =
      CoordinationMember
      |> where([m], m.coordination_id == ^coordination_id)
      |> Repo.all()

    case ans do
      [] -> false
      _ -> Enum.all?(ans, &(&1.decision == :not_answered))
    end
  end

  def deliver_acceptance_coordination_email_instructions(
        from_user,
        to_user,
        coordination_member,
        acceptance_coordination_url_fun
      )
      when is_function(acceptance_coordination_url_fun, 1) do
    if !Bright.Utils.Env.prod?() or Application.get_env(:bright, :dev_routes) do
      :ets.insert(
        :token,
        {"acceptance_coordination", to_user.email, to_user.name,
         acceptance_coordination_url_fun.(coordination_member.id)}
      )
    end

    UserNotifier.deliver_acceptance_coordination_instructions(
      from_user,
      to_user,
      acceptance_coordination_url_fun.(coordination_member.id)
    )
  end
end
