defmodule Bright.CareerWants do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerWants.{CareerWant, CareerWantJob}
  alias Bright.Jobs.Job

  @doc """
  Returns the list of career_wants.

  ## Examples

      iex> list_career_wants()
      [%CareerWant{}, ...]

  """
  def list_career_wants do
    from(c in CareerWant, order_by: c.position)
    |> Repo.all()
  end

  @doc """
  Gets a single career_want.

  Raises `Ecto.NoResultsError` if the Career want does not exist.

  ## Examples

      iex> get_career_want!(123)
      %CareerWant{}

      iex> get_career_want!(456)
      ** (Ecto.NoResultsError)

  """
  def get_career_want!(id), do: Repo.get!(CareerWant, id)

  @doc """
  Creates a career_want.

  ## Examples

      iex> create_career_want(%{field: value})
      {:ok, %CareerWant{}}

      iex> create_career_want(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want(attrs \\ %{}) do
    %CareerWant{}
    |> CareerWant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a career_want.

  ## Examples

      iex> update_career_want(career_want, %{field: new_value})
      {:ok, %CareerWant{}}

      iex> update_career_want(career_want, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_career_want(%CareerWant{} = career_want, attrs) do
    career_want
    |> CareerWant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a career_want.

  ## Examples

      iex> delete_career_want(career_want)
      {:ok, %CareerWant{}}

      iex> delete_career_want(career_want)
      {:error, %Ecto.Changeset{}}

  """
  def delete_career_want(%CareerWant{} = career_want) do
    Repo.delete(career_want)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want changes.

  ## Examples

      iex> change_career_want(career_want)
      %Ecto.Changeset{data: %CareerWant{}}

  """
  def change_career_want(%CareerWant{} = career_want, attrs \\ %{}) do
    CareerWant.changeset(career_want, attrs)
  end

  @doc """
  Creates a career_want_job.

  ## Examples

      iex> create_career_want_job(%{field: value})
      {:ok, %CareerWantJob{}}

      iex> create_career_want_job(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_career_want_job(attrs \\ %{}) do
    %CareerWantJob{}
    |> CareerWantJob.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking career_want_job changes.

  ## Examples

      iex> change_career_want_job(career_want_job)
      %Ecto.Changeset{data: %CareerWantJob{}}

  """
  def change_career_want_job(%CareerWantJob{} = career_want_job, attrs \\ %{}) do
    CareerWantJob.changeset(career_want_job, attrs)
  end

  @doc """
  Returns CareerWant Related SkillPanels group by CareerField

  ## Examples

      iex> list_skill_panels_group_by_career_field(id)
      %{%CareerField{} => [%SkillPanel{}, %SkillPanel{}]}
  """
  def list_skill_panels_group_by_career_field(id) do
    job_ids =
      from(cwj in CareerWantJob,
        where: cwj.career_want_id == ^id,
        select: cwj.job_id
      )

    from(job in Job,
      where: job.id in subquery(job_ids),
      join: sk in assoc(job, :skill_panels),
      join: cf in assoc(job, :career_fields),
      select: {cf, sk}
    )
    |> Repo.all()
    |> Enum.group_by(fn {cf, _sk} -> cf end, fn {_cf, sk} -> sk end)
  end
end
