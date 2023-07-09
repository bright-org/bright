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
end
