defmodule Bright.SkillPanels do
  @moduledoc """
  The SkillPanels context.
  """

  import Ecto.Query, warn: false

  alias Bright.Jobs.Job
  alias Ecto.Multi
  alias Bright.Repo

  alias Bright.SkillPanels.SkillPanel
  alias Bright.UserSkillPanels.UserSkillPanel
  alias Bright.SkillPanels.SkillClass
  alias Bright.SkillScores.SkillClassScore

  @doc """
  Returns the list of skill_panels.

  ## Examples

      iex> list_skill_panels()
      [%SkillPanel{}, ...]

  """
  def list_skill_panels do
    from(s in SkillPanel, order_by: s.updated_at)
    |> Repo.all()
  end

  @doc """
    Returns the list skill panes witin class and score by career_field name.

  ## Examples

      iex> list_users_skill_panels_by_career_field(user_id, career_field)
      [%SkillPanel{}]

  """
  def list_users_skill_panels_by_career_field(
        user_ids,
        career_field_name,
        page \\ 1
      ) do
    career_field_query =
      from(
        j in Job,
        join: cf in assoc(j, :career_fields),
        on: cf.name_en == ^career_field_name,
        join: s in assoc(j, :skill_panels),
        select: s,
        distinct: true
      )

    from(p in subquery(career_field_query),
      join: u in assoc(p, :user_skill_panels),
      on: u.skill_panel_id == p.id,
      join: class in assoc(p, :skill_classes),
      on: class.skill_panel_id == p.id,
      join: score in assoc(class, :skill_class_scores),
      on: class.id == score.skill_class_id,
      where: u.user_id in ^user_ids,
      where: score.user_id in ^user_ids,
      preload: [skill_classes: [skill_class_scores: ^SkillClassScore.user_ids_query(user_ids)]],
      order_by: p.updated_at,
      distinct: true
    )
    |> Repo.paginate(page: page, page_size: 10)
  end

  def list_users_skill_panels_all_career_field(
    user_ids,
    page \\ 1
  ) do
    career_field_query =
      from(
        j in Job,
        join: cf in assoc(j, :career_fields),
        join: s in assoc(j, :skill_panels),
        select: s,
        distinct: true
      )

    from(p in subquery(career_field_query),
      join: u in assoc(p, :user_skill_panels),
      on: u.skill_panel_id == p.id,
      join: class in assoc(p, :skill_classes),
      on: class.skill_panel_id == p.id,
      join: score in assoc(class, :skill_class_scores),
      on: class.id == score.skill_class_id,
      where: u.user_id in ^user_ids,
      where: score.user_id in ^user_ids,
      preload: [skill_classes: [skill_class_scores: ^SkillClassScore.user_ids_query(user_ids)]],
      order_by: p.updated_at,
      distinct: true
    )
    |> Repo.paginate(page: page, page_size: 10)
end

  def list_users_skill_panels(user_ids, page \\ 1) do
    from(u in UserSkillPanel,
      where: u.user_id in ^user_ids,
      join: s in assoc(u, :skill_panel),
      on: s.id == u.skill_panel_id,
      select: s,
      order_by: s.updated_at,
      distinct: true
    )
    |> Repo.paginate(page: page, page_size: 10)
  end

  @doc """
  For Skill Search slecet input options
  """
  def list_skill_panel_with_career_field() do
    from(
      j in Job,
      join: cf in assoc(j, :career_fields),
      join: s in assoc(j, :skill_panels),
      distinct: true,
      order_by: s.id,
      select: %{id: s.id, name: s.name, career_field: cf.name_en}
    )
    |> Repo.all()
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

  def get_user_skill_panel!(user, skill_panel_id) do
    user
    |> Ecto.assoc(:skill_panels)
    |> Bright.Repo.get_by!(id: skill_panel_id)
  end

  def get_user_skill_panel(user, skill_panel_id) do
    user
    |> Ecto.assoc(:skill_panels)
    |> Bright.Repo.get_by(id: skill_panel_id)
  end

  def get_user_latest_skill_panel(user) do
    from(q in SkillPanel,
      join: u in assoc(q, :user_skill_panels),
      where: u.user_id == ^user.id,
      order_by: [desc: u.is_star, desc: u.updated_at],
      limit: 1
    )
    |> Repo.one()
  end

  def get_skill_panel_with_career_fields!(id) do
    case Ecto.ULID.cast(id) do
      {:ok, ulid} ->
        SkillPanel
        |> preload(jobs: :career_fields)
        |> Repo.get!(ulid)

      :error ->
        raise Ecto.NoResultsError, queryable: SkillPanel
    end
  end

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

  @doc """
  Returns the list of skill_classes.

  ## Examples

      iex> list_skill_classes()
      [%SkillClass{}, ...]

  """
  def list_skill_classes(query \\ SkillClass) do
    Repo.all(query)
  end

  def list_skill_classes_by_skill_panel_id(skill_panel_id) do
    from(
      sc in SkillClass,
      where: sc.skill_panel_id == ^skill_panel_id
    )
    |> list_skill_classes()
  end

  def get_skill_class!(id), do: Repo.get!(SkillClass, id)

  def get_skill_class_by(condition) do
    Repo.get_by(SkillClass, condition)
  end

  @doc """
  オンボーディング、スキルアップで選択したスキルパネルの詳細の表示に使用する
  クラス１のユニットを一覧するためデフォルト値は１を指定

  ## Examples

      iex> get_skill_class_by_skill_panel_id()
      %SkillClass{}
  """

  def get_skill_class_by_skill_panel_id(skill_panel_id, class_num \\ 1) do
    query =
      from sc in SkillClass,
        where:
          sc.skill_panel_id == ^skill_panel_id and
            sc.class == ^class_num,
        preload: :skill_units

    Repo.one(query)
  end

  def get_all_skill_classes_by_skill_panel_id(skill_panel_id) do
    query =
      from sc in SkillClass,
        where: sc.skill_panel_id == ^skill_panel_id,
        order_by: [asc: sc.class],
        preload: :skill_units

    Repo.all(query)
  end
end
