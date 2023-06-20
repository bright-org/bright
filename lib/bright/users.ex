defmodule Bright.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Users.BrightUser

  @doc """
  Returns the list of bright_users.

  ## Examples

      iex> list_bright_users()
      [%BrightUser{}, ...]

  """
  def list_bright_users do
    Repo.all(BrightUser)
  end

  @doc """
  Gets a single bright_user.

  Raises `Ecto.NoResultsError` if the Bright user does not exist.

  ## Examples

      iex> get_bright_user!(123)
      %BrightUser{}

      iex> get_bright_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_bright_user!(id), do: Repo.get!(BrightUser, id)

  @doc """
  Creates a bright_user.

  ## Examples

      iex> create_bright_user(%{field: value})
      {:ok, %BrightUser{}}

      iex> create_bright_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_bright_user(attrs \\ %{}) do
    %BrightUser{}
    |> BrightUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a bright_user.

  ## Examples

      iex> update_bright_user(bright_user, %{field: new_value})
      {:ok, %BrightUser{}}

      iex> update_bright_user(bright_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_bright_user(%BrightUser{} = bright_user, attrs) do
    bright_user
    |> BrightUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a bright_user.

  ## Examples

      iex> delete_bright_user(bright_user)
      {:ok, %BrightUser{}}

      iex> delete_bright_user(bright_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_bright_user(%BrightUser{} = bright_user) do
    Repo.delete(bright_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking bright_user changes.

  ## Examples

      iex> change_bright_user(bright_user)
      %Ecto.Changeset{data: %BrightUser{}}

  """
  def change_bright_user(%BrightUser{} = bright_user, attrs \\ %{}) do
    BrightUser.changeset(bright_user, attrs)
  end
end
