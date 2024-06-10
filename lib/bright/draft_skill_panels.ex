defmodule Bright.DraftSkillPanels do
  @moduledoc """
  The DraftSkillPanels context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Bright.Repo

  alias Bright.DraftSkillPanels.SkillPanel
  alias Bright.DraftSkillPanels.DraftSkillClass

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
    |> Multi.delete_all(:draft_skill_classes, Ecto.assoc(skill_panel, :draft_skill_classes))
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
  Returns the list of draft_skill_classes.

  ## Examples

      iex> list_draft_skill_classes()
      [%DraftSkillClass{}, ...]

  """
  def list_draft_skill_classes(query \\ DraftSkillClass) do
    Repo.all(query)
  end

  @doc """
  Gets a single draft_skill_class.

  Raises `Ecto.NoResultsError` if the Draft skill does not exist.

  ## Examples

      iex> get_draft_skill_class!(123)
      %DraftSkillClass{}

      iex> get_draft_skill_class!(456)
      ** (Ecto.NoResultsError)

  """
  def get_draft_skill_class!(id), do: Repo.get!(DraftSkillClass, id)

  @doc """
  Creates a draft_skill_class.

  ## Examples

      iex> create_draft_skill_class(%{field: value})
      {:ok, %DraftSkillClass{}}

      iex> create_draft_skill_class(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_draft_skill_class(attrs \\ %{}) do
    %DraftSkillClass{}
    |> DraftSkillClass.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a draft_skill_class.

  ## Examples

      iex> update_draft_skill_class(draft_skill_class, %{field: new_value})
      {:ok, %DraftSkillClass{}}

      iex> update_draft_skill_class(draft_skill_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_draft_skill_class(%DraftSkillClass{} = draft_skill_class, attrs) do
    draft_skill_class
    |> DraftSkillClass.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a draft_skill_class.

  ## Examples

      iex> delete_draft_skill_class(draft_skill_class)
      {:ok, %DraftSkillClass{}}

      iex> delete_draft_skill_class(draft_skill_class)
      {:error, %Ecto.Changeset{}}

  """
  def delete_draft_skill_class(%DraftSkillClass{} = draft_skill_class) do
    Repo.delete(draft_skill_class)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draft_skill_class changes.

  ## Examples

      iex> change_draft_skill_class(draft_skill_class)
      %Ecto.Changeset{data: %DraftSkillClass{}}

  """
  def change_draft_skill_class(%DraftSkillClass{} = draft_skill_class, attrs \\ %{}) do
    DraftSkillClass.changeset(draft_skill_class, attrs)
  end

  @doc """
  スキルパネル配下の新しいスキルクラスを下書きスキルクラスに作成

  スキルパネルの作成ないしは編集で、新規追加したskill_classをドラフトにも作成する
  以降はドラフト管理ツール側でデータ生成／現行データへの反映、となる
  """
  def sync_new_skill_classes(skill_panel) do
    draft_skill_panel = get_skill_panel!(skill_panel.id)
    skill_classes = Ecto.assoc(skill_panel, :skill_classes) |> Repo.all()

    existing_trace_ids =
      from(q in Ecto.assoc(draft_skill_panel, :draft_skill_classes), select: q.trace_id)
      |> Repo.all()

    skill_classes
    |> Enum.reject(&(&1.trace_id in existing_trace_ids))
    |> Enum.map(fn new_skill_class ->
      Map.take(new_skill_class, [
        :skill_panel_id,
        :trace_id,
        :name,
        :class,
        :inserted_at,
        :updated_at
      ])
      |> Map.put(:id, Ecto.ULID.generate())
    end)
    |> then(&Repo.insert_all(DraftSkillClass, &1))
  end
end
