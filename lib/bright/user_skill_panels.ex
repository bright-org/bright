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

  def get_level_by_class_in_skills_panel(user_id) do
    from(user_skill_panel in UserSkillPanel,
      join: skill_panel in assoc(user_skill_panel, :skill_panel),
      join: skill_classes in assoc(skill_panel, :skill_classes),
      left_join: skill_class_scores in assoc(skill_classes, :skill_class_scores),
      on: skill_class_scores.user_id == ^user_id,
      where: user_skill_panel.user_id == ^user_id,
      order_by: [skill_panel.updated_at, skill_classes.class],
      preload: [
        skill_panel:
          {skill_panel, skill_classes: {skill_classes, skill_class_scores: skill_class_scores}}
      ]
    )
    |> Repo.all()
    |> get_level_by_class_in_skills_panel_data_convert()
  end

  defp get_level_by_class_in_skills_panel_data_convert(user_skill_panels) do
    user_skill_panels
    |> Enum.map(&get_level_by_class_in_skills_panel_convert_row/1)
  end

  defp get_level_by_class_in_skills_panel_convert_row(user_skill_panel) do
    %{name: name, skill_classes: skill_classes} = user_skill_panel.skill_panel

    skill_classes =
      skill_classes
      |> Enum.map(&get_level_by_class_in_skills_panel_convert_class_score_row/1)

    %{name: name, levels: skill_classes}
  end

  defp get_level_by_class_in_skills_panel_convert_class_score_row(%{skill_class_scores: []}),
    do: :none

  defp get_level_by_class_in_skills_panel_convert_class_score_row(%{
         skill_class_scores: skill_class_scores
       }) do
    skill_class_scores
    |> List.first()
    |> Map.get(:level)
  end
end
