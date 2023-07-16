defmodule Bright.Onboardings do
  @moduledoc """
  The Onboardings context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Onboardings.UserOnboarding

  @doc """
  Returns the list of user_onboardings.

  ## Examples

      iex> list_user_onboardings()
      [%UserOnboarding{}, ...]

  """
  def list_user_onboardings do
    Repo.all(UserOnboarding)
  end

  @doc """
  Gets a single user_onboarding.

  Raises `Ecto.NoResultsError` if the User onboarding does not exist.

  ## Examples

      iex> get_user_onboarding!(123)
      %UserOnboarding{}

      iex> get_user_onboarding!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_onboarding!(id), do: Repo.get!(UserOnboarding, id)

  @doc """
  Creates a user_onboarding.

  ## Examples

      iex> create_user_onboarding(%{field: value})
      {:ok, %UserOnboarding{}}

      iex> create_user_onboarding(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_onboarding(attrs \\ %{}) do
    %UserOnboarding{}
    |> UserOnboarding.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_onboarding.

  ## Examples

      iex> update_user_onboarding(user_onboarding, %{field: new_value})
      {:ok, %UserOnboarding{}}

      iex> update_user_onboarding(user_onboarding, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_onboarding(%UserOnboarding{} = user_onboarding, attrs) do
    user_onboarding
    |> UserOnboarding.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_onboarding.

  ## Examples

      iex> delete_user_onboarding(user_onboarding)
      {:ok, %UserOnboarding{}}

      iex> delete_user_onboarding(user_onboarding)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_onboarding(%UserOnboarding{} = user_onboarding) do
    Repo.delete(user_onboarding)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_onboarding changes.

  ## Examples

      iex> change_user_onboarding(user_onboarding)
      %Ecto.Changeset{data: %UserOnboarding{}}

  """
  def change_user_onboarding(%UserOnboarding{} = user_onboarding, attrs \\ %{}) do
    UserOnboarding.changeset(user_onboarding, attrs)
  end

  alias Bright.Onboardings.OnboardingWant
  # alias Bright.Accounts.User

  @doc """
  Returns the list of onboarding_wants.

  ## Examples

      iex> list_onboarding_wants()
      [%OnboardingWant{}, ...]

  """
  def list_onboarding_wants do
    Repo.all(OnboardingWant)
    #    Repo.all(from(o in OnboardingWant, where: o.position == 1, order_by: [desc: o.position]))
    # Repo.all(from o in OnboardingWant, join: u in User, on: o.inserted_at >= u.inserted_at)
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
