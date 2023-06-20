defmodule Bright.SkillPanels do
  @moduledoc """
  The SkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
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
      {:ok, %{skill_panel: %SkillPanel{}, skill_classes: {count, nil}}

      iex> delete_skill_panel(skill_panel)
      {:error, %{skill_panel: %Ecto.Changeset{}, skill_classes: _}}

  """
  def delete_skill_panel(%SkillPanel{} = skill_panel) do
    Multi.new()
    |> Multi.delete_all(:skill_classes, Ecto.assoc(skill_panel, :skill_classes))
    |> Multi.delete(:skill_panel, skill_panel)
    |> Repo.transaction()
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
end
