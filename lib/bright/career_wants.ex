defmodule Bright.CareerWants do
  @moduledoc """
  The Jobs context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.CareerWants.{CareerWant, CareerWantJob}

  @doc """
  Returns the list of career_wants.

  ## Examples

      iex> list_career_wants()
      [%CareerWant{}, ...]

  """
  def list_career_wants do
    Repo.all(CareerWant)
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

  def list_career_want_jobs_with_career_wants do
    query =
      from cw in CareerWant,
        join: cwj in CareerWantJob,
        on: cwj.career_want_id == cw.id,
        group_by: [cw.id],
        order_by: [cw.position],
        select: %{
          career_want_id: cw.id,
          career_want_name: cw.name
        }

    Repo.all(query)
  end

  @doc """
  やりたいことに関連づいているキャリアフィールドを取得し、やりたいこと単位でリストに
  [
    [
      %{
        career_field_name_en: "engineer",
        career_field_name_ja: "エンジニア"
      },
      %{
        career_field_name_en: "designer",
        career_field_name_ja: "デザイナー"
      }
    ],
    [
      %{
        career_field_name_en: "designer",
        career_field_name_ja: "デザイナー"
      }
    ],
    [
      %{
        career_field_name_en: "infra",
        career_field_name_ja: "インフラ"
      }
    ]
  ]
  """
  def list_career_wants_jobs_with_career_fields do
    query =
      from cw in CareerWant,
        join: cwj in CareerWantJob,
        on: cwj.career_want_id == cw.id,
        join: j in Job,
        on: cwj.job_id == j.id,
        join: cf in CareerField,
        on: j.career_field_id == cf.id,
        group_by: [cw.id, cf.id],
        order_by: [asc: cw.position, asc: cf.position],
        select: %{
          career_want_id: cw.id,
          career_field_name_ja: cf.name_ja,
          career_field_name_en: cf.name_en
        }

    Repo.all(query)
    |> Enum.group_by(fn x -> x.career_want_id end)
    |> Enum.map(fn {_key, value} ->
      Enum.map(value, fn x ->
        %{
          career_field_name_ja: x.career_field_name_ja,
          career_field_name_en: x.career_field_name_en
        }
      end)
    end)
  end
end
