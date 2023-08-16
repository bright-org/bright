defmodule Bright.UserSkillPanels do
  @moduledoc """
  The UserSkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.UserSkillPanels.UserSkillPanel

  @doc """
  Returns the list of user_skill_panels.

  ## Examples

      iex> list_user_skill_panels()
      [%UserSkillPanel{}, ...]

  """
  def list_user_skill_panels do
    Repo.all(UserSkillPanel)
    |> Repo.preload([:user, :skill_panel])
  end

  # TODO  ダミー用あとで消す
  def list_user_skill_panels_dev(user_id) do
    UserSkillPanel
    |> where([p], p.user_id == ^user_id)
    |> select([p], p.skill_panel_id)
    |> Repo.all()
  end

  @doc """
  Gets a single user_skill_panel.

  Raises `Ecto.NoResultsError` if the User skill panel does not exist.

  ## Examples

      iex> get_user_skill_panel!(123)
      %UserSkillPanel{}

      iex> get_user_skill_panel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_skill_panel!(id),
    do: Repo.get!(UserSkillPanel, id) |> Repo.preload([:user, :skill_panel])

  @doc """
  Creates a user_skill_panel.

  ## Examples

      iex> create_user_skill_panel(%{field: value})
      {:ok, %UserSkillPanel{}}

      iex> create_user_skill_panel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_skill_panel(attrs \\ %{}) do
    %UserSkillPanel{}
    |> UserSkillPanel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_skill_panel.

  ## Examples

      iex> update_user_skill_panel(user_skill_panel, %{field: new_value})
      {:ok, %UserSkillPanel{}}

      iex> update_user_skill_panel(user_skill_panel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_skill_panel(%UserSkillPanel{} = user_skill_panel, attrs) do
    user_skill_panel
    |> UserSkillPanel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_skill_panel.

  ## Examples

      iex> delete_user_skill_panel(user_skill_panel)
      {:ok, %UserSkillPanel{}}

      iex> delete_user_skill_panel(user_skill_panel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_skill_panel(%UserSkillPanel{} = user_skill_panel) do
    Repo.delete(user_skill_panel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_skill_panel changes.

  ## Examples

      iex> change_user_skill_panel(user_skill_panel)
      %Ecto.Changeset{data: %UserSkillPanel{}}

  """
  def change_user_skill_panel(%UserSkillPanel{} = user_skill_panel, attrs \\ %{}) do
    UserSkillPanel.changeset(user_skill_panel, attrs)
  end

  def touch_user_skill_panel_updated(user, skill_panel) do
    Repo.get_by!(UserSkillPanel, user_id: user.id, skill_panel_id: skill_panel.id)
    |> change_user_skill_panel()
    |> Repo.update(force: true)
  end
end
