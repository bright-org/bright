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
end
