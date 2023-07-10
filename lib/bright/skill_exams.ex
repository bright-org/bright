defmodule Bright.SkillExams do
  @moduledoc """
  The SkillExams context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillExams.SkillExam

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

  alias Bright.SkillExams.SkillExamResult

  @doc """
  Returns the list of skill_exam_results.

  ## Examples

      iex> list_skill_exam_results()
      [%SkillExamResult{}, ...]

  """
  def list_skill_exam_results do
    Repo.all(SkillExamResult)
  end

  @doc """
  Gets a single skill_exam_result.

  Raises `Ecto.NoResultsError` if the Skill exam result does not exist.

  ## Examples

      iex> get_skill_exam_result!(123)
      %SkillExamResult{}

      iex> get_skill_exam_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_exam_result!(id), do: Repo.get!(SkillExamResult, id)

  @doc """
  Creates a skill_exam_result.

  ## Examples

      iex> create_skill_exam_result(%{field: value})
      {:ok, %SkillExamResult{}}

      iex> create_skill_exam_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_exam_result(attrs \\ %{}) do
    %SkillExamResult{}
    |> SkillExamResult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_exam_result.

  ## Examples

      iex> update_skill_exam_result(skill_exam_result, %{field: new_value})
      {:ok, %SkillExamResult{}}

      iex> update_skill_exam_result(skill_exam_result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_exam_result(%SkillExamResult{} = skill_exam_result, attrs) do
    skill_exam_result
    |> SkillExamResult.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_exam_result.

  ## Examples

      iex> delete_skill_exam_result(skill_exam_result)
      {:ok, %SkillExamResult{}}

      iex> delete_skill_exam_result(skill_exam_result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_exam_result(%SkillExamResult{} = skill_exam_result) do
    Repo.delete(skill_exam_result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_exam_result changes.

  ## Examples

      iex> change_skill_exam_result(skill_exam_result)
      %Ecto.Changeset{data: %SkillExamResult{}}

  """
  def change_skill_exam_result(%SkillExamResult{} = skill_exam_result, attrs \\ %{}) do
    SkillExamResult.changeset(skill_exam_result, attrs)
  end
end
