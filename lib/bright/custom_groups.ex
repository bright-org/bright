defmodule Bright.CustomGroups do
  @moduledoc """
  The CustomGroups context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CustomGroups.CustomGroup

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
end
