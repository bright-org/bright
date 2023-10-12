defmodule Bright.UserJobProfiles do
  @moduledoc """
  The UserJobProfiles context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.UserJobProfiles.UserJobProfile

  @doc """
  Returns the list of user_job_profiles.

  ## Examples

      iex> list_user_job_profiles()
      [%UserJobProfile{}, ...]

  """
  def list_user_job_profiles do
    Repo.all(UserJobProfile)
  end

  @doc """
  Gets a single user_job_profile.

  Raises `Ecto.NoResultsError` if the User job profile does not exist.

  ## Examples

      iex> get_user_job_profile!(123)
      %UserJobProfile{}

      iex> get_user_job_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_job_profile!(id), do: Repo.get!(UserJobProfile, id)

  @doc """
  Gets a single user_job_profile by user_id.

  Raises `Ecto.NoResultsError` if the User job profile does not exist.

  ## Examples

      iex> get_user_job_profile_by_user_id!(123)
      %UserJobProfile{}

      iex> get_user_job_profile_by_user_id!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_job_profile_by_user_id!(user_id),
    do: Repo.get_by!(UserJobProfile, user_id: user_id)

  @doc """
  Creates a user_job_profile.

  ## Examples

      iex> create_user_job_profile(%{field: value})
      {:ok, %UserJobProfile{}}

      iex> create_user_job_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_job_profile(attrs \\ %{}) do
    %UserJobProfile{}
    |> UserJobProfile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_job_profile.

  ## Examples

      iex> update_user_job_profile(user_job_profile, %{field: new_value})
      {:ok, %UserJobProfile{}}

      iex> update_user_job_profile(user_job_profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_job_profile(%UserJobProfile{} = user_job_profile, attrs) do
    user_job_profile
    |> UserJobProfile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_job_profile.

  ## Examples

      iex> delete_user_job_profile(user_job_profile)
      {:ok, %UserJobProfile{}}

      iex> delete_user_job_profile(user_job_profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_job_profile(%UserJobProfile{} = user_job_profile) do
    Repo.delete(user_job_profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_job_profile changes.

  ## Examples

      iex> change_user_job_profile(user_job_profile)
      %Ecto.Changeset{data: %UserJobProfile{}}

  """
  def change_user_job_profile(%UserJobProfile{} = user_job_profile, attrs \\ %{}) do
    UserJobProfile.changeset(user_job_profile, attrs)
  end
end
