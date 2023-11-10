defmodule Bright.Recruits do
  @moduledoc """
  The Recruits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Recruits.InterviewMember
  alias Bright.Repo

  alias Bright.Recruits.Interview

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

  def get_interview_with_member_users!(id) do
    Interview
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

  def get_interview_member!(id) do
    InterviewMember
    |> preload(:interview)
    |> Repo.get(id)
  end
end
