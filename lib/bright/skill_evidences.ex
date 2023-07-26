defmodule Bright.SkillEvidences do
  @moduledoc """
  The SkillEvidences context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.SkillEvidences.{SkillEvidence, SkillEvidencePost}

  @doc """
  Returns the list of skill_evidences.

  ## Examples

      iex> list_skill_evidences()
      [%SkillEvidence{}, ...]

  """
  def list_skill_evidences do
    Repo.all(SkillEvidence)
  end

  @doc """
  Gets a single skill_evidence.

  Raises `Ecto.NoResultsError` if the Skill evidence does not exist.

  ## Examples

      iex> get_skill_evidence!(123)
      %SkillEvidence{}

      iex> get_skill_evidence!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_evidence!(id), do: Repo.get!(SkillEvidence, id)

  @doc """
  Gets a single skill_evidence by condition
  """
  def get_skill_evidence_by(condition) do
    Repo.get_by(SkillEvidence, condition)
  end

  @doc """
  Creates a skill_evidence.

  ## Examples

      iex> create_skill_evidence(%{field: value})
      {:ok, %SkillEvidence{}}

      iex> create_skill_evidence(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_evidence(attrs \\ %{}) do
    %SkillEvidence{}
    |> SkillEvidence.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a skill_evidence.

  ## Examples

      iex> update_skill_evidence(skill_evidence, %{field: new_value})
      {:ok, %SkillEvidence{}}

      iex> update_skill_evidence(skill_evidence, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_skill_evidence(%SkillEvidence{} = skill_evidence, attrs) do
    skill_evidence
    |> SkillEvidence.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a skill_evidence.

  ## Examples

      iex> delete_skill_evidence(skill_evidence)
      {:ok, %SkillEvidence{}}

      iex> delete_skill_evidence(skill_evidence)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_evidence(%SkillEvidence{} = skill_evidence) do
    Repo.delete(skill_evidence)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_evidence changes.

  ## Examples

      iex> change_skill_evidence(skill_evidence)
      %Ecto.Changeset{data: %SkillEvidence{}}

  """
  def change_skill_evidence(%SkillEvidence{} = skill_evidence, attrs \\ %{}) do
    SkillEvidence.changeset(skill_evidence, attrs)
  end

  @doc """
  Returns the list of skill_evidence_posts.

  ## Examples

      iex> list_skill_evidence_posts()
      [%SkillEvidencePost{}, ...]

  """
  def list_skill_evidence_posts(query \\ SkillEvidencePost) do
    query
    |> Repo.all()
  end

  @doc """
  Gets a single skill_evidence_post.

  Raises `Ecto.NoResultsError` if the Skill evidence post does not exist.

  ## Examples

      iex> get_skill_evidence_post!(123)
      %SkillEvidencePost{}

      iex> get_skill_evidence_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_skill_evidence_post!(id), do: Repo.get!(SkillEvidencePost, id)

  @doc """
  Creates a skill_evidence_post.

  ## Examples

      iex> create_skill_evidence_post(%{field: value})
      {:ok, %SkillEvidencePost{}}

      iex> create_skill_evidence_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_skill_evidence_post(skill_evidence, user, attrs \\ %{}) do
    %SkillEvidencePost{
      skill_evidence_id: skill_evidence.id,
      user_id: user.id
    }
    |> SkillEvidencePost.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Deletes a skill_evidence_post.

  ## Examples

      iex> delete_skill_evidence_post(skill_evidence_post)
      {:ok, %SkillEvidencePost{}}

      iex> delete_skill_evidence_post(skill_evidence_post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_skill_evidence_post(%SkillEvidencePost{} = skill_evidence_post) do
    Repo.delete(skill_evidence_post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking skill_evidence_post changes.

  ## Examples

      iex> change_skill_evidence_post(skill_evidence_post)
      %Ecto.Changeset{data: %SkillEvidencePost{}}

  """
  def change_skill_evidence_post(%SkillEvidencePost{} = skill_evidence_post, attrs \\ %{}) do
    SkillEvidencePost.changeset(skill_evidence_post, attrs)
  end
end
