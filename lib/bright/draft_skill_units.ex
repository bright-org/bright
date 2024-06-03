defmodule Bright.DraftSkillUnits do
  @moduledoc """
  The DraftSkillUnits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.DraftSkillUnits.DraftSkillUnit
  alias Bright.DraftSkillUnits.DraftSkillCategory
  alias Bright.DraftSkillUnits.DraftSkill

  @doc """
  Returns the list of draft_skill_units.

  ## Examples

      iex> list_draft_skill_units()
      [%DraftSkillUnit{}, ...]

  """
  def list_draft_skill_units(query \\ DraftSkillUnit) do
    Repo.all(query)
  end

  @doc """
  Gets a single draft_skill_unit.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_draft_skill_unit!(123)
      %DraftSkillUnit{}

      iex> get_draft_skill_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_draft_skill_unit!(id), do: Repo.get!(DraftSkillUnit, id)

  @doc """
  Creates a draft_skill_unit.

  ## Examples

      iex> create_draft_skill_unit(%{field: value})
      {:ok, %DraftSkillUnit{}}

      iex> create_draft_skill_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_draft_skill_unit(attrs \\ %{}) do
    %DraftSkillUnit{}
    |> DraftSkillUnit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a draft_skill_unit.

  ## Examples

      iex> update_draft_skill_unit(draft_skill_unit, %{field: new_value})
      {:ok, %DraftSkillUnit{}}

      iex> update_draft_skill_unit(draft_skill_unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_draft_skill_unit(%DraftSkillUnit{} = draft_skill_unit, attrs) do
    draft_skill_unit
    |> DraftSkillUnit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a draft_skill_unit.

  ## Examples

      iex> delete_draft_skill_unit(draft_skill_unit)
      {:ok, %DraftSkillUnit{}}

      iex> delete_draft_skill_unit(draft_skill_unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_draft_skill_unit(%DraftSkillUnit{} = draft_skill_unit) do
    Repo.delete(draft_skill_unit)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draft_skill_unit changes.

  ## Examples

      iex> change_draft_skill_unit(draft_skill_unit)
      %Ecto.Changeset{data: %DraftSkillUnit{}}

  """
  def change_draft_skill_unit(%DraftSkillUnit{} = draft_skill_unit, attrs \\ %{}) do
    DraftSkillUnit.changeset(draft_skill_unit, attrs)
  end

  @doc """
  Gets a single draft_skill_category.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_draft_skill_category!(123)
      %DraftSkillCategory{}

      iex> get_draft_skill_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_draft_skill_category!(id), do: Repo.get!(DraftSkillCategory, id)

  @doc """
  Updates a draft_skill_category.

  ## Examples

      iex> update_draft_skill_category(draft_skill_category, %{field: new_value})
      {:ok, %DraftSkillCategory{}}

      iex> update_draft_skill_category(draft_skill_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_draft_skill_category(%DraftSkillCategory{} = draft_skill_category, attrs) do
    draft_skill_category
    |> DraftSkillCategory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draft_skill_category changes.

  ## Examples

      iex> change_draft_skill_category(draft_skill_category)
      %Ecto.Changeset{data: %DraftSkillCategory{}}

  """
  def change_draft_skill_category(%DraftSkillCategory{} = draft_skill_category, attrs \\ %{}) do
    DraftSkillCategory.changeset(draft_skill_category, attrs)
  end

  alias Bright.DraftSkillUnits.DraftSkill

  @doc """
  Returns the list of draft_skills.

  ## Examples

      iex> list_draft_skills()
      [%DraftSkill{}, ...]

  """
  def list_draft_skills do
    Repo.all(DraftSkill)
  end

  @doc """
  Gets a single draft_skill.

  Raises `Ecto.NoResultsError` if the Draft skill does not exist.

  ## Examples

      iex> get_draft_skill!(123)
      %DraftSkill{}

      iex> get_draft_skill!(456)
      ** (Ecto.NoResultsError)

  """
  def get_draft_skill!(id), do: Repo.get!(DraftSkill, id)

  @doc """
  Creates a draft_skill.

  ## Examples

      iex> create_draft_skill(%{field: value})
      {:ok, %DraftSkill{}}

      iex> create_draft_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_draft_skill(attrs \\ %{}) do
    draft_skill_category = get_draft_skill_category!(attrs["draft_skill_category_id"])

    position =
      draft_skill_category
      |> Ecto.assoc(:draft_skills)
      |> Repo.aggregate(:max, :position)
      |> Kernel.+(1)

    %DraftSkill{}
    |> DraftSkill.changeset(attrs |> Map.put("position", position))
    |> Repo.insert()
  end

  @doc """
  Updates a draft_skill.

  ## Examples

      iex> update_draft_skill(draft_skill, %{field: new_value})
      {:ok, %DraftSkill{}}

      iex> update_draft_skill(draft_skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_draft_skill(%DraftSkill{} = draft_skill, attrs) do
    draft_skill
    |> DraftSkill.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a draft_skill.

  ## Examples

      iex> delete_draft_skill(draft_skill)
      {:ok, %DraftSkill{}}

      iex> delete_draft_skill(draft_skill)
      {:error, %Ecto.Changeset{}}

  """
  def delete_draft_skill(%DraftSkill{} = draft_skill) do
    Repo.delete(draft_skill)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking draft_skill changes.

  ## Examples

      iex> change_draft_skill(draft_skill)
      %Ecto.Changeset{data: %DraftSkill{}}

  """
  def change_draft_skill(%DraftSkill{} = draft_skill, attrs \\ %{}) do
    DraftSkill.changeset(draft_skill, attrs)
  end

  @doc """
  位置(position)を入れ替える

  positionを属性でもっていればよくStructを問わない
  """
  def replace_position(struct_1, struct_2) do
    changeset_tmp = Ecto.Changeset.change(struct_2, position: -1)
    changeset_1 = Ecto.Changeset.change(struct_1, position: struct_2.position)
    changeset_2 = Ecto.Changeset.change(struct_2, position: struct_1.position)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:position_change_tmp, changeset_tmp)
    |> Ecto.Multi.update(:position_change_1, changeset_1)
    |> Ecto.Multi.update(:position_change_2, changeset_2)
    |> Repo.transaction()
  end
end
