defmodule Bright.Teams do
  @moduledoc """
  チームを操作するモジュール
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

  alias Bright.Teams.TeamMemberUsers

  @doc """
  Returns the list of team_member_users.

  ## Examples

      iex> list_team_member_users()
      [%TeamMemberUsers{}, ...]

  """
  def list_team_member_users do
    Repo.all(TeamMemberUsers)
  end

  @doc """
  Gets a single team_member_users.

  Raises `Ecto.NoResultsError` if the Team member users does not exist.

  ## Examples

      iex> get_team_member_users!(123)
      %TeamMemberUsers{}

      iex> get_team_member_users!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_member_users!(id), do: Repo.get!(TeamMemberUsers, id)

  @doc """
  Creates a team_member_users.

  ## Examples

      iex> create_team_member_users(%{field: value})
      {:ok, %TeamMemberUsers{}}

      iex> create_team_member_users(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_member_users(attrs \\ %{}) do
    %TeamMemberUsers{}
    |> TeamMemberUsers.changeset(attrs)
    |> Repo.insert()
  end

  def craete_team_member_users(attrs) do
    attrs
    |> Enum.each(fn x ->
      create_team_member_users(x)
    end)
  end

  @doc """
  Updates a team_member_users.

  ## Examples

      iex> update_team_member_users(team_member_users, %{field: new_value})
      {:ok, %TeamMemberUsers{}}

      iex> update_team_member_users(team_member_users, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_member_users(%TeamMemberUsers{} = team_member_users, attrs) do
    team_member_users
    |> TeamMemberUsers.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_member_users.

  ## Examples

      iex> delete_team_member_users(team_member_users)
      {:ok, %TeamMemberUsers{}}

      iex> delete_team_member_users(team_member_users)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_member_users(%TeamMemberUsers{} = team_member_users) do
    Repo.delete(team_member_users)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_member_users changes.

  ## Examples

      iex> change_team_member_users(team_member_users)
      %Ecto.Changeset{data: %TeamMemberUsers{}}

  """
  def change_team_member_users(%TeamMemberUsers{} = team_member_users, attrs \\ %{}) do
    TeamMemberUsers.changeset(team_member_users, attrs)
  end

  @doc """
  ユーザーが所属するチームの一覧取得
  """
  def list_joined_teams_by_user_id(user_id) do
    TeamMemberUsers
    |> where([member_user], member_user.user_id == ^user_id)
    |> preload(:team)
    |> Repo.all()
  end

  @spec create_team_multi(any, atom | %{:id => any, optional(any) => any}, any) :: any
  @doc """
  チームおよびメンバーの一括登録
  """
  def create_team_multi(name, admin_user, member_users) do
    team_attr = %{
      name: name,
      enable_hr_functions: false
    }

    # 作成者本人は自動的に管理者となる
    admin_attr = %{
      user_id: admin_user.id,
      is_admin: true,
      # プライマリ判定実装まで強制true
      is_primary: true
    }

    member_attr =
      member_users
      |> Enum.map(fn x ->
        %{
          user_id: x.id,
          is_admin: false,
          # メンバーのプライマリ判定は承認後に実施する為一旦falseとする
          is_primary: false
        }
      end)

    team_changeset =
      %Team{}
      |> Team.changeset(team_attr)

    team_member_user_changesets =
      [admin_attr | member_attr]
      |> Enum.map(fn attrs ->
        change_team_member_users(%TeamMemberUsers{}, attrs)
      end)

    team_and_members_changeset =
      team_changeset
      |> Ecto.Changeset.put_assoc(:member_users, team_member_user_changesets)

    {:ok, result} =
      Ecto.Multi.new()
      |> Ecto.Multi.insert(:team, team_and_members_changeset)
      |> Repo.transaction()

    {:ok, Map.get(result, :team)}
  end
end
