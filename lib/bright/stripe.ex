defmodule Bright.Stripe do
  @moduledoc """
  The Stripe context.
  """

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Stripe.StripePrice

  @doc """
  Returns the list of stripe_prices.

  ## Examples

      iex> list_stripe_prices()
      [%StripePrice{}, ...]

  """
  def list_stripe_prices do
    StripePrice
    |> preload(:subscription_plan)
    |> Repo.all()
  end

  @doc """
  Gets a single stripe_price.

  Raises `Ecto.NoResultsError` if the Stripe price does not exist.

  ## Examples

      iex> get_stripe_price!(123)
      %StripePrice{}

      iex> get_stripe_price!(456)
      ** (Ecto.NoResultsError)

  """
  def get_stripe_price!(id) do
    StripePrice
    |> preload(:subscription_plan)
    |> Repo.get!(id)
  end

  @doc """
  Creates a stripe_price.

  ## Examples

      iex> create_stripe_price(%{field: value})
      {:ok, %StripePrice{}}

      iex> create_stripe_price(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_stripe_price(attrs \\ %{}) do
    %StripePrice{}
    |> StripePrice.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a stripe_price.

  ## Examples

      iex> update_stripe_price(stripe_price, %{field: new_value})
      {:ok, %StripePrice{}}

      iex> update_stripe_price(stripe_price, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_stripe_price(%StripePrice{} = stripe_price, attrs) do
    stripe_price
    |> StripePrice.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a stripe_price.

  ## Examples

      iex> delete_stripe_price(stripe_price)
      {:ok, %StripePrice{}}

      iex> delete_stripe_price(stripe_price)
      {:error, %Ecto.Changeset{}}

  """
  def delete_stripe_price(%StripePrice{} = stripe_price) do
    Repo.delete(stripe_price)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking stripe_price changes.

  ## Examples

      iex> change_stripe_price(stripe_price)
      %Ecto.Changeset{data: %StripePrice{}}

  """
  def change_stripe_price(%StripePrice{} = stripe_price, attrs \\ %{}) do
    StripePrice.changeset(stripe_price, attrs)
  end
end
