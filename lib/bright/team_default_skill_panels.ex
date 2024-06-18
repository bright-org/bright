defmodule Bright.TeamDefaultSkillPanels do
  @moduledoc """
  チームの初期パネル操作するモジュール
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Teams.TeamDefaultSkillPanel

  @doc """
  Returns the list of team_default_skill_panels.

  ## Examples

      iex> list_team_default_skill_panels()
      [%TeamDefaultSkillPanel{}, ...]

  """
  def list_team_default_skill_panels do
    Repo.all(TeamDefaultSkillPanel)
    |> Repo.preload([:team, :skill_panel])
  end

  @doc """
  Gets a single team_default_skill_panel.

  Raises `Ecto.NoResultsError` if the Team default skill panel does not exist.

  ## Examples

      iex> get_team_default_skill_panel!(123)
      %TeamDefaultSkillPanel{}

      iex> get_team_default_skill_panel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_team_default_skill_panel!(id),
    do: Repo.get!(TeamDefaultSkillPanel, id) |> Repo.preload([:team, :skill_panel])

  @doc """
  Creates a team_default_skill_panel.

  ## Examples

      iex> create_team_default_skill_panel(%{field: value})
      {:ok, %TeamDefaultSkillPanel{}}

      iex> create_team_default_skill_panel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_team_default_skill_panel(attrs \\ %{}) do
    %TeamDefaultSkillPanel{}
    |> TeamDefaultSkillPanel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a team_default_skill_panel.

  ## Examples

      iex> update_team_default_skill_panel(team_default_skill_panel, %{field: new_value})
      {:ok, %TeamDefaultSkillPanel{}}

      iex> update_team_default_skill_panel(team_default_skill_panel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_team_default_skill_panel(%TeamDefaultSkillPanel{} = team_default_skill_panel, attrs) do
    team_default_skill_panel
    |> TeamDefaultSkillPanel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a team_default_skill_panel.

  ## Examples

      iex> delete_team_default_skill_panel(team_default_skill_panel)
      {:ok, %TeamDefaultSkillPanel{}}

      iex> delete_team_default_skill_panel(team_default_skill_panel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_team_default_skill_panel(%TeamDefaultSkillPanel{} = team_default_skill_panel) do
    Repo.delete(team_default_skill_panel)
  end

  def get_team_default_skill_panel_from_team_id(team_id) do
    from(td in TeamDefaultSkillPanel,
      left_join: s in assoc(td, :skill_panel),
      where: td.team_id == ^team_id,
      limit: 1,
      select: s,
      order_by: s.id
    )
    |> Repo.one()
  end

  def set_team_default_skill_panel_from_team_id(team_id, nil) do
    query = team_default_skill_panel_from_team_id_query(team_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_all, query)
    |> Repo.transaction()
  end

  def set_team_default_skill_panel_from_team_id(team_id, skill_panel_id) do
    query = team_default_skill_panel_from_team_id_query(team_id)

    Ecto.Multi.new()
    |> Ecto.Multi.delete_all(:delete_all, query)
    |> Ecto.Multi.insert(:team_default_skill_panel, %TeamDefaultSkillPanel{
      team_id: team_id,
      skill_panel_id: skill_panel_id
    })
    |> Repo.transaction()
  end

  defp team_default_skill_panel_from_team_id_query(team_id) do
    from(td in TeamDefaultSkillPanel,
      where: td.team_id == ^team_id
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking team_default_skill_panel changes.

  ## Examples

      iex> change_team_default_skill_panel(team_default_skill_panel)
      %Ecto.Changeset{data: %TeamDefaultSkillPanel{}}

  """
  def change_team_default_skill_panel(
        %TeamDefaultSkillPanel{} = team_default_skill_panel,
        attrs \\ %{}
      ) do
    TeamDefaultSkillPanel.changeset(team_default_skill_panel, attrs)
  end
end
