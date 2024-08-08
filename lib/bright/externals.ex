defmodule Bright.Externals do
  @moduledoc """
  The Externals context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Externals.ExternalTokens

  @doc """
  Returns the list of external_tokens.

  ## Examples

      iex> list_external_tokens()
      [%ExternalTokens{}, ...]

  """
  def list_external_tokens do
    Repo.all(ExternalTokens)
  end

  @doc """
  Gets a single external_tokens.

  Raises `Ecto.NoResultsError` if the External tokens does not exist.

  ## Examples

      iex> get_external_tokens!(123)
      %ExternalTokens{}

      iex> get_external_tokens!(456)
      ** (Ecto.NoResultsError)

  """
  def get_external_tokens!(id), do: Repo.get!(ExternalTokens, id)

  @doc """
  Creates a external_tokens.

  ## Examples

      iex> create_external_tokens(%{field: value})
      {:ok, %ExternalTokens{}}

      iex> create_external_tokens(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_external_tokens(attrs \\ %{}) do
    %ExternalTokens{}
    |> ExternalTokens.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a external_tokens.

  ## Examples

      iex> update_external_tokens(external_tokens, %{field: new_value})
      {:ok, %ExternalTokens{}}

      iex> update_external_tokens(external_tokens, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_external_tokens(%ExternalTokens{} = external_tokens, attrs) do
    external_tokens
    |> ExternalTokens.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a external_tokens.

  ## Examples

      iex> delete_external_tokens(external_tokens)
      {:ok, %ExternalTokens{}}

      iex> delete_external_tokens(external_tokens)
      {:error, %Ecto.Changeset{}}

  """
  def delete_external_tokens(%ExternalTokens{} = external_tokens) do
    Repo.delete(external_tokens)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking external_tokens changes.

  ## Examples

      iex> change_external_tokens(external_tokens)
      %Ecto.Changeset{data: %ExternalTokens{}}

  """
  def change_external_tokens(%ExternalTokens{} = external_tokens, attrs \\ %{}) do
    ExternalTokens.changeset(external_tokens, attrs)
  end
end
