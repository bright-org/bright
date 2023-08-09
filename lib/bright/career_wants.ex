defmodule Bright.CareerWants do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerWants.{CareerWant, CareerWantSkillPanel}

  @doc """
  Returns the list of career_wants.

  ## Examples

      iex> list_career_wants()
      [%CareerWant{}, ...]

  """
  def list_career_wants do
    Repo.all(CareerWant)
  end

  @doc """
  Gets a single career_want.

  Raises `Ecto.NoResultsError` if the Career want does not exist.

  ## Examples

      iex> get_career_want!(123)
      %CareerWant{}

      iex> get_career_want!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_want!(id), do: Repo.get!(CareerWant, id)

  @doc """
  Creates a career_want.

  ## Examples

      iex> create_career_want(%{field: value})
      {:ok, %CareerWant{}}

      iex> create_career_want(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want(attrs \\ %{}) do
    %CareerWant{}
    |> CareerWant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_want.

  ## Examples

      iex> update_career_want(career_want, %{field: new_value})
      {:ok, %CareerWant{}}

      iex> update_career_want(career_want, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_want(%CareerWant{} = career_want, attrs) do
    career_want
    |> CareerWant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_want.

  ## Examples

      iex> delete_career_want(career_want)
      {:ok, %CareerWant{}}

      iex> delete_career_want(career_want)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_want(%CareerWant{} = career_want) do
    Repo.delete(career_want)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want changes.

  ## Examples

      iex> change_career_want(career_want)
      %Ecto.Changeset{data: %CareerWant{}}

  """
  def change_career_want(%CareerWant{} = career_want, attrs \\ %{}) do
    CareerWant.changeset(career_want, attrs)
  end

  @doc """
  Creates a career_want_skill_panel.

  ## Examples

      iex> create_career_want_skill_panel(%{field: value})
      {:ok, %CareerWant{}}

      iex> create_career_want_skill_panel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want_skill_panel(attrs \\ %{}) do
    %CareerWantSkillPanel{}
    |> CareerWantSkillPanel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want_skill_panel changes.

  ## Examples

      iex> change_career_want_skil_panel(career_want_skill_panel)
      %Ecto.Changeset{data: %CareerWantSkillPanel{}}

  """
  def change_career_want_skill_panel(
        %CareerWantSkillPanel{} = career_want_skill_panel,
        attrs \\ %{}
      ) do
    CareerWantSkillPanel.changeset(career_want_skill_panel, attrs)
  end
end
