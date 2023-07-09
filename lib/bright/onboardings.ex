defmodule Bright.Onboardings do
  @moduledoc """
  The Onboardings context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Onboardings.UserOnboardings

  @doc """
  Returns the list of user_onboardings.

  ## Examples

      iex> list_user_onboardings()
      [%UserOnboardings{}, ...]

  """
  def list_user_onboardings do
    Repo.all(UserOnboardings)
  end

  @doc """
  Gets a single user_onboardings.

  Raises `Ecto.NoResultsError` if the User onboardings does not exist.

  ## Examples

      iex> get_user_onboardings!(123)
      %UserOnboardings{}

      iex> get_user_onboardings!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_onboardings!(id), do: Repo.get!(UserOnboardings, id)

  @doc """
  Creates a user_onboardings.

  ## Examples

      iex> create_user_onboardings(%{field: value})
      {:ok, %UserOnboardings{}}

      iex> create_user_onboardings(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_onboardings(attrs \\ %{}) do
    %UserOnboardings{}
    |> UserOnboardings.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_onboardings.

  ## Examples

      iex> update_user_onboardings(user_onboardings, %{field: new_value})
      {:ok, %UserOnboardings{}}

      iex> update_user_onboardings(user_onboardings, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_onboardings(%UserOnboardings{} = user_onboardings, attrs) do
    user_onboardings
    |> UserOnboardings.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_onboardings.

  ## Examples

      iex> delete_user_onboardings(user_onboardings)
      {:ok, %UserOnboardings{}}

      iex> delete_user_onboardings(user_onboardings)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_onboardings(%UserOnboardings{} = user_onboardings) do
    Repo.delete(user_onboardings)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_onboardings changes.

  ## Examples

      iex> change_user_onboardings(user_onboardings)
      %Ecto.Changeset{data: %UserOnboardings{}}

  """
  def change_user_onboardings(%UserOnboardings{} = user_onboardings, attrs \\ %{}) do
    UserOnboardings.changeset(user_onboardings, attrs)
  end

  alias Bright.Onboardings.OnboardingWant

  @doc """
  Returns the list of onboarding_wants.

  ## Examples

      iex> list_onboarding_wants()
      [%OnboardingWant{}, ...]

  """
  def list_onboarding_wants do
    Repo.all(OnboardingWant)
  end

  @doc """
  Gets a single onboarding_want.

  Raises `Ecto.NoResultsError` if the Onboarding want does not exist.

  ## Examples

      iex> get_onboarding_want!(123)
      %OnboardingWant{}

      iex> get_onboarding_want!(456)
      ** (Ecto.NoResultsError)

  """
  def get_onboarding_want!(id), do: Repo.get!(OnboardingWant, id)

  @doc """
  Creates a onboarding_want.

  ## Examples

      iex> create_onboarding_want(%{field: value})
      {:ok, %OnboardingWant{}}

      iex> create_onboarding_want(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_onboarding_want(attrs \\ %{}) do
    %OnboardingWant{}
    |> OnboardingWant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a onboarding_want.

  ## Examples

      iex> update_onboarding_want(onboarding_want, %{field: new_value})
      {:ok, %OnboardingWant{}}

      iex> update_onboarding_want(onboarding_want, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_onboarding_want(%OnboardingWant{} = onboarding_want, attrs) do
    onboarding_want
    |> OnboardingWant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a onboarding_want.

  ## Examples

      iex> delete_onboarding_want(onboarding_want)
      {:ok, %OnboardingWant{}}

      iex> delete_onboarding_want(onboarding_want)
      {:error, %Ecto.Changeset{}}

  """
  def delete_onboarding_want(%OnboardingWant{} = onboarding_want) do
    Repo.delete(onboarding_want)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking onboarding_want changes.

  ## Examples

      iex> change_onboarding_want(onboarding_want)
      %Ecto.Changeset{data: %OnboardingWant{}}

  """
  def change_onboarding_want(%OnboardingWant{} = onboarding_want, attrs \\ %{}) do
    OnboardingWant.changeset(onboarding_want, attrs)
  end
end
