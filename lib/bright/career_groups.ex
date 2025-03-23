defmodule Bright.CareerGroups do
  @moduledoc """
  The CareerGroups context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerGroups.CareerGroup

  @doc """
  Returns the list of career_groups.

  ## Examples

      iex> list_career_groups()
      [%CareerGroup{}, ...]

  """
  def list_career_groups do
    Repo.all(CareerGroup)
  end

  def list_career_groups_with_career_field(type) when type == :engineer do
    CareerGroup
    |> where(type: ^type)
    |> preload(:career_fields)
    |> Repo.all()
  end

  def list_career_groups_with_career_field(_type) do
    CareerGroup
    |> preload(:career_fields)
    |> Repo.all()
  end

  def list_career_group_career_fields(:all) do
    cg =
      CareerGroup
      |> preload(:career_fields)
      |> Repo.all()

    cf_ids =
      Enum.map(cg, & &1.career_fields)
      |> List.flatten()
      |> Enum.map(& &1.id)
      |> Enum.uniq()

    other_cf =
      Bright.CareerFields.CareerField
      |> where([cf], cf.id not in ^cf_ids)
      |> Repo.all()

    Enum.concat(cg, [%{name: :other, career_fields: other_cf}])
  end

  def list_career_group_career_fields(type) do
    CareerGroup
    |> where(type: ^type)
    |> preload(:career_fields)
    |> Repo.one()
    |> case do
      nil ->
        []

      cg ->
        cg
        |> Map.get(:career_fields)
        |> Enum.sort_by(& &1.position)
    end
  end

  @doc """
  Gets a single career_group.

  Raises `Ecto.NoResultsError` if the Career group does not exist.

  ## Examples

      iex> get_career_group!(123)
      %CareerGroup{}

      iex> get_career_group!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_group!(id), do: Repo.get!(CareerGroup, id)

  @doc """
  Gets a single career_group's related career_fields.

  Raises `Ecto.Query.CastError` if type not a member in User.type Enum's

  ## Examples

      iex> get_career_group_related_career_field(:engineer)
      [%CareerField{}]

      iex> get_career_group_related_career_field(:none)
      ** (Ecto.Query.CastError)

  """

  def get_career_group_related_career_field(type) do
    group =
      CareerGroup
      |> where(type: ^type)
      |> preload(:career_fields)
      |> Repo.one()

    if is_nil(group), do: [], else: group.career_fields
  end

  @doc """
  Creates a career_group.

  ## Examples

      iex> create_career_group(%{field: value})
      {:ok, %CareerGroup{}}

      iex> create_career_group(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_group(attrs \\ %{}) do
    %CareerGroup{}
    |> CareerGroup.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_group.

  ## Examples

      iex> update_career_group(career_group, %{field: new_value})
      {:ok, %CareerGroup{}}

      iex> update_career_group(career_group, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_group(%CareerGroup{} = career_group, attrs) do
    career_group
    |> CareerGroup.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_group.

  ## Examples

      iex> delete_career_group(career_group)
      {:ok, %CareerGroup{}}

      iex> delete_career_group(career_group)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_group(%CareerGroup{} = career_group) do
    Repo.delete(career_group)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_group changes.

  ## Examples

      iex> change_career_group(career_group)
      %Ecto.Changeset{data: %CareerGroup{}}

  """
  def change_career_group(%CareerGroup{} = career_group, attrs \\ %{}) do
    CareerGroup.changeset(career_group, attrs)
  end
end
