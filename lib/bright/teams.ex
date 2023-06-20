defmodule Bright.Teams do
  @moduledoc """
  The Teams context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Teams.Team

  @doc """
  Returns the list of teams.

  ## Examples

      iex> list_teams()
      [%Team{}, ...]

  """
  def list_teams do
    Repo.all(Team)
  end

  @doc """
  Gets a single team.

  Raises `Ecto.NoResultsError` if the Team does not exist.

  ## Examples

      iex> get_team!(123)
      %Team{}

      iex> get_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team!(id) do

    Team
    |> Repo.get!(id)
    |> Repo.preload(:auther_bright_user)
    |> Repo.preload(:brigit_users)

  end

  @doc """
  Creates a team.

  ## Examples

      iex> create_team(%{field: value})
      {:ok, %Team{}}

      iex> create_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team(attrs \\ %{}) do
    %Team{}
    |> Team.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team.

  ## Examples

      iex> update_team(team, %{field: new_value})
      {:ok, %Team{}}

      iex> update_team(team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team(%Team{} = team, attrs) do
    team
    |> Team.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team.

  ## Examples

      iex> delete_team(team)
      {:ok, %Team{}}

      iex> delete_team(team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team(%Team{} = team) do
    Repo.delete(team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team changes.

  ## Examples

      iex> change_team(team)
      %Ecto.Changeset{data: %Team{}}

  """
  def change_team(%Team{} = team, attrs \\ %{}) do
    Team.changeset(team, attrs)
  end

  alias Bright.Teams.UserJoinedTeam

  @doc """
  Returns the list of user_joined_teams.

  ## Examples

      iex> list_user_joined_teams()
      [%UserJoinedTeam{}, ...]

  """
  def list_user_joined_teams do
    Repo.all(UserJoinedTeam)
  end

  @doc """
  Gets a single user_joined_team.

  Raises `Ecto.NoResultsError` if the User joined team does not exist.

  ## Examples

      iex> get_user_joined_team!(123)
      %UserJoinedTeam{}

      iex> get_user_joined_team!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_joined_team!(id), do: Repo.get!(UserJoinedTeam, id)

  @doc """
  Creates a user_joined_team.

  ## Examples

      iex> create_user_joined_team(%{field: value})
      {:ok, %UserJoinedTeam{}}

      iex> create_user_joined_team(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_joined_team(attrs \\ %{}) do
    %UserJoinedTeam{}
    |> UserJoinedTeam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_joined_team.

  ## Examples

      iex> update_user_joined_team(user_joined_team, %{field: new_value})
      {:ok, %UserJoinedTeam{}}

      iex> update_user_joined_team(user_joined_team, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_joined_team(%UserJoinedTeam{} = user_joined_team, attrs) do
    user_joined_team
    |> UserJoinedTeam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_joined_team.

  ## Examples

      iex> delete_user_joined_team(user_joined_team)
      {:ok, %UserJoinedTeam{}}

      iex> delete_user_joined_team(user_joined_team)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_joined_team(%UserJoinedTeam{} = user_joined_team) do
    Repo.delete(user_joined_team)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_joined_team changes.

  ## Examples

      iex> change_user_joined_team(user_joined_team)
      %Ecto.Changeset{data: %UserJoinedTeam{}}

  """
  def change_user_joined_team(%UserJoinedTeam{} = user_joined_team, attrs \\ %{}) do
    UserJoinedTeam.changeset(user_joined_team, attrs)
  end
end
