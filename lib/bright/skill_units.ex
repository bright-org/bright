defmodule Bright.SkillUnits do
  @moduledoc """
  The SkillUnits context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillPanels
  alias Bright.SkillUnits.SkillUnit
  alias Bright.SkillUnits.SkillCategory
  alias Bright.SkillUnits.Skill
  alias Bright.SkillUnits.SkillClassUnit

  @doc """
  Returns the list of skill_units.

  ## Examples

      iex> list_skill_units()
      [%SkillUnit{}, ...]

  """
  def list_skill_units(query \\ SkillUnit) do
    Repo.all(query)
  end

  def list_skill_units_on_class(skill_class) do
    from(q in SkillClassUnit,
      where: q.skill_class_id == ^skill_class.id,
      join: su in assoc(q, :skill_unit),
      order_by: {:asc, q.position},
      select: su
    )
    |> Repo.all()
  end

  @doc """
  Gets a single skill_unit.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_skill_unit!(123)
      %SkillUnit{}

      iex> get_skill_unit!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_unit!(id), do: Repo.get!(SkillUnit, id)

  def get_skill_unit(id), do: Repo.get(SkillUnit, id)

  @doc """
  Creates a skill_unit.

  ## Examples

      iex> create_skill_unit(%{field: value})
      {:ok, %SkillUnit{}}

      iex> create_skill_unit(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_unit(attrs) do
    %SkillUnit{}
    |> SkillUnit.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a skill_unit.

  ## Examples

      iex> create_skill_unit(skill_class, %{field: value})
      {:ok, %SkillUnit{}}

      iex> create_skill_unit(skill_class, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_unit(skill_class, attrs) do
    position = get_max_position(skill_class, :skill_class_units) |> Kernel.+(1)

    Repo.transaction(fn ->
      %SkillUnit{}
      |> SkillUnit.changeset(attrs)
      |> Repo.insert()
      |> case do
        {:ok, skill_unit} ->
          Repo.insert!(%SkillClassUnit{
            skill_class_id: skill_class.id,
            skill_unit_id: skill_unit.id,
            position: position
          })

          # NOTE: 編集ツールの表形式表示の都合上、少なくとも1つスキルがないと出せないので必ず1つダミーでスキルを作成している
          create_skill_category(%{
            "skill_unit_id" => skill_unit.id,
            "name" => "<カテゴリ名を入力してください>",
            "position" => 1
          })

          skill_unit

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a skill_unit.

  ## Examples

      iex> update_skill_unit(skill_unit, %{field: new_value})
      {:ok, %SkillUnit{}}

      iex> update_skill_unit(skill_unit, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_unit(%SkillUnit{} = skill_unit, attrs) do
    skill_unit
    |> SkillUnit.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_unit.

  ## Examples

      iex> delete_skill_unit(skill_unit)
      {:ok, %SkillUnit{}}

      iex> delete_skill_unit(skill_unit)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_unit(%SkillUnit{} = skill_unit) do
    Repo.transaction(fn ->
      Ecto.assoc(skill_unit, :skill_categories)
      |> Repo.all()
      |> Enum.each(&delete_skill_category/1)

      Repo.delete!(skill_unit)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_unit changes.

  ## Examples

      iex> change_skill_unit(skill_unit)
      %Ecto.Changeset{data: %SkillUnit{}}

  """
  def change_skill_unit(%SkillUnit{} = skill_unit, attrs \\ %{}) do
    SkillUnit.changeset(skill_unit, attrs)
  end

  @doc """
  Gets a single skill_category.

  Raises `Ecto.NoResultsError` if the Skill unit does not exist.

  ## Examples

      iex> get_skill_category!(123)
      %SkillCategory{}

      iex> get_skill_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_category!(id), do: Repo.get!(SkillCategory, id)

  def get_skill_category(id), do: Repo.get(SkillCategory, id)

  @doc """
  Creates a skill_category.

  ## Examples

      iex> create_skill_category(%{field: value})
      {:ok, {%SkillCategory{}, %Skill{}}}

      iex> create_skill_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_category(attrs) do
    # NOTE: 編集ツールの表形式表示の都合上、少なくとも1つスキルがないと出せないので必ず1つダミーでスキルを作成している
    skill_unit = get_skill_unit!(attrs["skill_unit_id"])
    position = get_max_position(skill_unit, :skill_categories) |> Kernel.+(1)

    Repo.transaction(fn ->
      %SkillCategory{}
      |> SkillCategory.changeset(attrs |> Map.put("position", position))
      |> Repo.insert()
      |> case do
        {:ok, skill_category} ->
          Repo.insert!(%Skill{
            skill_category_id: skill_category.id,
            name: "<スキル名を入力してください>",
            position: 1
          })

          skill_category

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  @doc """
  Updates a skill_category.

  ## Examples

      iex> update_skill_category(skill_category, %{field: new_value})
      {:ok, %SkillCategory{}}

      iex> update_skill_category(skill_category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_category(%SkillCategory{} = skill_category, attrs) do
    skill_category
    |> SkillCategory.changeset(attrs)
    |> Repo.update()
  end

  def delete_skill_category(%SkillCategory{} = skill_category) do
    Repo.transaction(fn ->
      Ecto.assoc(skill_category, :skills)
      |> Repo.all()
      |> Enum.each(&delete_skill/1)

      Repo.delete!(skill_category)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_category changes.

  ## Examples

      iex> change_skill_category(skill_category)
      %Ecto.Changeset{data: %SkillCategory{}}

  """
  def change_skill_category(%SkillCategory{} = skill_category, attrs \\ %{}) do
    SkillCategory.changeset(skill_category, attrs)
  end

  @doc """
  Gets skills
  """
  def list_skills(query \\ Skill) do
    Repo.all(query)
  end

  @doc """
  Gets skills on skill_class
  """
  def list_skills_on_skill_class(skill_class) do
    Skill.skill_class_query(skill_class.id)
    |> list_skills()
  end

  @doc """
  Gets a single skill
  """
  def get_skill!(id), do: Repo.get!(Skill, id)

  @doc """
  Creates a skill.

  ## Examples

      iex> create_skill(%{field: value})
      {:ok, %Skill{}}

      iex> create_skill(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill(attrs \\ %{}) do
    skill_category = get_skill_category!(attrs["skill_category_id"])
    position = get_max_position(skill_category, :skills) |> Kernel.+(1)

    %Skill{}
    |> Skill.changeset(attrs |> Map.put("position", position))
    |> Repo.insert()
  end

  @doc """
  Updates a skill.

  ## Examples

      iex> update_skill(skill, %{field: new_value})
      {:ok, %Skill{}}

      iex> update_skill(skill, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill(%Skill{} = skill, attrs) do
    skill
    |> Skill.changeset(attrs)
    |> Repo.update()
  end

  def delete_skill(%Skill{} = skill) do
    Repo.transaction(fn ->
      Ecto.assoc(skill, :skill_evidences)
      |> Repo.all()
      |> Enum.each(&Repo.delete/1)

      Repo.delete!(skill)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill changes.

  ## Examples

      iex> change_skill(skill)
      %Ecto.Changeset{data: %Skill{}}

  """
  def change_skill(%Skill{} = skill, attrs \\ %{}) do
    Skill.changeset(skill, attrs)
  end

  def get_skill_class_unit_by(condition) do
    Repo.get_by(SkillClassUnit, condition)
  end

  def list_skill_categorys_on_unit(skill_unit) do
    from(q in SkillCategory,
      where: q.skill_unit_id == ^skill_unit.id,
      order_by: {:asc, q.position}
    )
    |> Repo.all()
  end

  def create_skill_class_unit(
        %SkillPanels.SkillClass{} = skill_class,
        %SkillUnit{} = skill_unit
      ) do
    position = get_max_position(skill_class, :skill_class_units)

    # 重複していないならば追加する
    get_skill_class_unit_by(
      skill_class_id: skill_class.id,
      skill_unit_id: skill_unit.id
    )
    |> if do
      nil
    else
      Repo.insert(%SkillClassUnit{
        skill_class_id: skill_class.id,
        skill_unit_id: skill_unit.id,
        position: position + 1
      })
    end
  end

  def delete_skill_class_unit(
        %SkillPanels.SkillClass{} = skill_class,
        %SkillUnit{} = skill_unit
      ) do
    Repo.get_by(
      SkillClassUnit,
      skill_class_id: skill_class.id,
      skill_unit_id: skill_unit.id
    )
    |> Repo.delete()
  end

  @doc """
  表示位置の最大を取得する
  """
  def get_max_position(struct, relation) do
    struct |> Ecto.assoc(relation) |> Repo.aggregate(:max, :position) |> Kernel.||(0)
  end

  @doc """
  表示位置(position)を入れ替える

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
