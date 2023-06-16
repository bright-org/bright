defmodule Bright.SkillPanels do
  @moduledoc """
  The SkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillPanels.SkillPanel

  @doc """
  Returns the list of skill_panels.

  ## Examples

      iex> list_skill_panels()
      [%SkillPanel{}, ...]

  """
  def list_skill_panels do
    Repo.all(SkillPanel)
  end

  @doc """
  Gets a single skill_panel.

  Raises `Ecto.NoResultsError` if the Skill panel does not exist.

  ## Examples

      iex> get_skill_panel!(123)
      %SkillPanel{}

      iex> get_skill_panel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_panel!(id), do: Repo.get!(SkillPanel, id)

  @doc """
  Creates a skill_panel.

  ## Examples

      iex> create_skill_panel(%{field: value})
      {:ok, %SkillPanel{}}

      iex> create_skill_panel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_panel(attrs \\ %{}) do
    %SkillPanel{}
    |> SkillPanel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_panel.

  ## Examples

      iex> update_skill_panel(skill_panel, %{field: new_value})
      {:ok, %SkillPanel{}}

      iex> update_skill_panel(skill_panel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_panel(%SkillPanel{} = skill_panel, attrs) do
    skill_panel
    |> SkillPanel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_panel.

  ## Examples

      iex> delete_skill_panel(skill_panel)
      {:ok, %SkillPanel{}}

      iex> delete_skill_panel(skill_panel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_panel(%SkillPanel{} = skill_panel) do
    Repo.delete(skill_panel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_panel changes.

  ## Examples

      iex> change_skill_panel(skill_panel)
      %Ecto.Changeset{data: %SkillPanel{}}

  """
  def change_skill_panel(%SkillPanel{} = skill_panel, attrs \\ %{}) do
    SkillPanel.changeset(skill_panel, attrs)
  end

  alias Bright.SkillPanels.SkillClass

  @doc """
  Returns the list of skill_classes.

  ## Examples

      iex> list_skill_classes()
      [%SkillClass{}, ...]

  """
  def list_skill_classes do
    Repo.all(SkillClass)
  end

  @doc """
  Gets a single skill_class.

  Raises `Ecto.NoResultsError` if the Skill class does not exist.

  ## Examples

      iex> get_skill_class!(123)
      %SkillClass{}

      iex> get_skill_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_class!(id), do: Repo.get!(SkillClass, id)

  @doc """
  Creates a skill_class.

  ## Examples

      iex> create_skill_class(%{field: value})
      {:ok, %SkillClass{}}

      iex> create_skill_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_class(attrs \\ %{}) do
    %SkillClass{}
    |> SkillClass.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_class.

  ## Examples

      iex> update_skill_class(skill_class, %{field: new_value})
      {:ok, %SkillClass{}}

      iex> update_skill_class(skill_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_class(%SkillClass{} = skill_class, attrs) do
    skill_class
    |> SkillClass.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_class.

  ## Examples

      iex> delete_skill_class(skill_class)
      {:ok, %SkillClass{}}

      iex> delete_skill_class(skill_class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_class(%SkillClass{} = skill_class) do
    Repo.delete(skill_class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_class changes.

  ## Examples

      iex> change_skill_class(skill_class)
      %Ecto.Changeset{data: %SkillClass{}}

  """
  def change_skill_class(%SkillClass{} = skill_class, attrs \\ %{}) do
    SkillClass.changeset(skill_class, attrs)
  end
end
