defmodule Bright.CustomGroups do
  @moduledoc """
  The CustomGroups context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Teams
  alias Bright.CustomGroups.{CustomGroup, CustomGroupMemberUser}

  @doc """
  Returns the list of custom_groups.

  ## Examples

      iex> list_custom_groups()
      [%CustomGroup{}, ...]

  """
  def list_custom_groups do
    Repo.all(CustomGroup)
  end

  @doc """
  Returns the list of custom_groups of given user_id.
  """
  def list_user_custom_groups(user_id) do
    query_user_custom_groups(user_id)
    |> Repo.all()
  end

  def list_user_custom_groups(user_id, page_params) do
    query_user_custom_groups(user_id)
    |> Repo.paginate(page_params)
  end

  defp query_user_custom_groups(user_id) do
    from(c in CustomGroup,
      where: c.user_id == ^user_id,
      order_by: {:asc, :inserted_at}
    )
  end

  @doc """
  Returns the list of custom_group member user.

  At the same time, check referencing privileges and delete.

  ## Examples

      iex> list_and_filter_valid_users(custom_group, user)
      [%User{}, ...]

  """
  def list_and_filter_valid_users(custom_group, user) do
    preload_custom_group_user(custom_group)
    |> case do
      nil ->
        []

      custom_group ->
        {valid_users, _invalid_users} = filter_valid_users(custom_group, user)
        valid_users
    end
  end

  @doc """
  カスタムグループのメンバーを現在も参照可能か判定して可能なユーザーを返す。不可の場合は削除をメンバー削除を実行
  """
  def filter_valid_users(custom_group) do
    user = Repo.preload(custom_group, :user).user
    filter_valid_users(custom_group, user)
  end

  def filter_valid_users(custom_group, user) do
    members = Enum.map(custom_group.member_users, & &1.user)

    # 参照可能かどうかを確認している
    {valid_users, invalid_users} = Enum.split_with(members, &custom_group_assignable?(user, &1))

    delete_custom_group_member_users_from_user_ids(
      custom_group,
      Enum.map(invalid_users, & &1.id)
    )

    {valid_users, invalid_users}
  end

  @doc """
  Gets a single custom_group.

  Raises `Ecto.NoResultsError` if the Custom group does not exist.

  ## Examples

      iex> get_custom_group!(123)
      %CustomGroup{}

      iex> get_custom_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_custom_group!(id), do: Repo.get!(CustomGroup, id)

  @doc """
  Gets a single custom_group by given condition.

  Raises `Ecto.NoResultsError` if the Custom group does not exist.
  """
  def get_custom_group_by!(condition), do: Repo.get_by!(CustomGroup, condition)

  @doc """
  Creates a custom_group.

  ## Examples

      iex> create_custom_group(%{field: value})
      {:ok, %CustomGroup{}}

      iex> create_custom_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_custom_group(attrs \\ %{}) do
    %CustomGroup{}
    |> CustomGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a custom_group.

  ## Examples

      iex> update_custom_group(custom_group, %{field: new_value})
      {:ok, %CustomGroup{}}

      iex> update_custom_group(custom_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_custom_group(%CustomGroup{} = custom_group, attrs) do
    custom_group
    |> CustomGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a custom_group.

  ## Examples

      iex> delete_custom_group(custom_group)
      {:ok, %CustomGroup{}}

      iex> delete_custom_group(custom_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_custom_group(%CustomGroup{} = custom_group) do
    Repo.delete(custom_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking custom_group changes.

  ## Examples

      iex> change_custom_group(custom_group)
      %Ecto.Changeset{data: %CustomGroup{}}

  """
  def change_custom_group(%CustomGroup{} = custom_group, attrs \\ %{}) do
    CustomGroup.changeset(custom_group, attrs)
  end

  defp custom_group_assignable?(user, member) do
    Teams.joined_teams_by_user_id!(user.id, member.id)
    true
  rescue
    Ecto.NoResultsError -> false
  end

  defp preload_custom_group_user(custom_group) do
    from(
      c in CustomGroup,
      join: mu in assoc(c, :member_users),
      join: u in assoc(mu, :user),
      where: c.id == ^custom_group.id,
      preload: [member_users: {mu, user: u}]
    )
    |> Repo.one()
  end

  defp delete_custom_group_member_users_from_user_ids(custom_group, user_ids) do
    from(
      mu in CustomGroupMemberUser,
      where: mu.custom_group_id == ^custom_group.id,
      where: mu.user_id in ^user_ids
    )
    |> Repo.delete_all()
  end
end
