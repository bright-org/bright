defmodule Bright.SkillExams do
  @moduledoc """
  The SkillExams context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillExams.SkillExam
  alias Bright.Utils.Percentage

  @doc """
  Returns the list of skill_exams.

  ## Examples

      iex> list_skill_exams()
      [%SkillExam{}, ...]

  """
  def list_skill_exams do
    Repo.all(SkillExam)
  end

  @doc """
  Gets a single skill_exam.

  Raises `Ecto.NoResultsError` if the Skill exam does not exist.

  ## Examples

      iex> get_skill_exam!(123)
      %SkillExam{}

      iex> get_skill_exam!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_exam!(id), do: Repo.get!(SkillExam, id)

  @doc """
  Gets a single skill_exam by condition
  """
  def get_skill_exam_by!(condition) do
    Repo.get_by!(SkillExam, condition)
  end

  @doc """
  Creates a skill_exam.

  ## Examples

      iex> create_skill_exam(%{field: value})
      {:ok, %SkillExam{}}

      iex> create_skill_exam(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_exam(attrs \\ %{}) do
    %SkillExam{}
    |> SkillExam.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_exam.

  ## Examples

      iex> update_skill_exam(skill_exam, %{field: new_value})
      {:ok, %SkillExam{}}

      iex> update_skill_exam(skill_exam, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_exam(%SkillExam{} = skill_exam, attrs) do
    skill_exam
    |> SkillExam.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_exam.

  ## Examples

      iex> delete_skill_exam(skill_exam)
      {:ok, %SkillExam{}}

      iex> delete_skill_exam(skill_exam)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_exam(%SkillExam{} = skill_exam) do
    Repo.delete(skill_exam)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_exam changes.

  ## Examples

      iex> change_skill_exam(skill_exam)
      %Ecto.Changeset{data: %SkillExam{}}

  """
  def change_skill_exam(%SkillExam{} = skill_exam, attrs \\ %{}) do
    SkillExam.changeset(skill_exam, attrs)
  end

  @doc """
  試験受験率(%)を返す。
  完全達成時に100%と表示し99.5%などでは99%と表示するため切り捨てている。
  """
  def calc_touch_percentage(value, size) do
    Percentage.calc_floor_percentage(value, size)
  end
end
