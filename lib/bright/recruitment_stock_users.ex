defmodule Bright.RecruitmentStockUsers do
  @moduledoc """
  The RecruitmentStockUsers context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.RecruitmentStockUsers.RecruitmentStockUser

  @doc """
  Returns the list of recruitment_stock_users.

  ## Examples

      iex> list_recruitment_stock_users(recruiter_id, %{page: 1, page_size: 10})
      [%RecruitmentStockUser{}, ...]

  """
  def list_recruitment_stock_users(recruiter_id, page_param) do
    from(stock_user in RecruitmentStockUser,
      join: user in assoc(stock_user, :user),
      where: stock_user.recruiter_id == ^recruiter_id,
      order_by: [asc: stock_user.inserted_at]
    )
    |> Repo.paginate(page_param)
  end

  @doc """
  Gets a single recruitment_stock_user.

  Raises `Ecto.NoResultsError` if the User onboarding does not exist.

  ## Examples

      iex> get_recruitment_stock_user!(123)
      %RecruitmentStockUser{}

      iex> get_recruitment_stock_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recruitment_stock_user!(id), do: Repo.get!(RecruitmentStockUser, id)

  @doc """
  Creates a recruitment_stock_user.

  ## Examples

      iex> create_recruitment_stock_user(%{field: value})
      {:ok, %RecruitmentStockUser{}}

      iex> create_recruitment_stock_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recruitment_stock_user(attrs \\ %{}) do
    %RecruitmentStockUser{}
    |> RecruitmentStockUser.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a recruitment_stock_user.

  ## Examples

      iex> update_recruitment_stock_user(recruitment_stock_user, %{field: new_value})
      {:ok, %RecruitmentStockUser{}}

      iex> update_recruitment_stock_user(recruitment_stock_user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recruitment_stock_user(%RecruitmentStockUser{} = recruitment_stock_user, attrs) do
    recruitment_stock_user
    |> RecruitmentStockUser.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a recruitment_stock_user.

  ## Examples

      iex> delete_recruitment_stock_user(recruitment_stock_user)
      {:ok, %RecruitmentStockUser{}}

      iex> delete_recruitment_stock_user(recruitment_stock_user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recruitment_stock_user(%RecruitmentStockUser{} = recruitment_stock_user) do
    Repo.delete(recruitment_stock_user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recruitment_stock_user changes.

  ## Examples

      iex> change_recruitment_stock_user(recruitment_stock_user)
      %Ecto.Changeset{data: %RecruitmentStockUser{}}

  """
  def change_recruitment_stock_user(
        %RecruitmentStockUser{} = recruitment_stock_user,
        attrs \\ %{}
      ) do
    RecruitmentStockUser.changeset(recruitment_stock_user, attrs)
  end
end
