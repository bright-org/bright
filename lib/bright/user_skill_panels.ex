defmodule Bright.UserSkillPanels do
  @moduledoc """
  The UserSkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillPanels
  alias Bright.SkillScores
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

  def get_star!(user_id, skill_panel_id) do
    from(u in UserSkillPanel,
      where:
        u.user_id == ^user_id and
          u.skill_panel_id == ^skill_panel_id,
      select: u.is_star
    )
    |> Repo.one!()
  end

  @doc """
  Creates a user_skill_panel.

  合わせてスキルパネルに属するスキルクラスの各スコア用のレコードを生成している

  ## Examples

      iex> create_user_skill_panel(%{field: value})
      {:ok, %{user_skill_panel: %UserSkillPanel{}, skill_class_scores: []}}

      iex> create_user_skill_panel(%{field: bad_value})
      {:error, :user_skill_panel, %Ecto.Changeset{}, %{}}

  """
  def create_user_skill_panel(attrs \\ %{}) do
    Ecto.Multi.new()
    |> Ecto.Multi.insert(:user_skill_panel, fn _ ->
      %UserSkillPanel{}
      |> UserSkillPanel.changeset(attrs)
    end)
    |> Ecto.Multi.run(:skill_class_scores, fn _repo, %{user_skill_panel: user_skill_panel} ->
      result =
        SkillPanels.list_skill_classes_by_skill_panel_id(user_skill_panel.skill_panel_id)
        |> Enum.map(&SkillScores.create_skill_class_score(&1, user_skill_panel.user_id))

      status = if Enum.all?(result, &(elem(&1, 0) == :ok)), do: :ok, else: :error
      values = Enum.map(result, &elem(&1, 1))
      {status, values}
    end)
    |> Repo.transaction()
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
