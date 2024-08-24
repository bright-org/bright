defmodule Bright.Stripe do
  @moduledoc """
  The Stripe context.
  """

  use BrightWeb, :verified_routes

  import Ecto.Query, warn: false
  alias Bright.Repo

  alias Bright.Stripe.{UserStripeCustomer, StripePrice, Checkout}
  alias Bright.Subscriptions.SubscriptionPlan
  require Logger

  @doc """
  Creates a Stripe Checkout session.
  """
  def start_checkout_session(user, plan_code, stripe_lookup_key \\ "default") do
    # plan_codeからprice_idを取得する
    price_id = get_stripe_price_id_by_subscription_plan_code(plan_code, stripe_lookup_key)
    Logger.info("#######price_id: #{price_id}")

    # Stripe顧客ID検索・作成
    case get_stripe_customer_id_by_user_id(user.id) do
      nil ->
        # 顧客IDが存在しない場合、Stripeに顧客IDを作成&user_stripe_customersテーブルに追加
        case create_stripe_customer(user.id, user.email) do
          {:ok, stripe_customer_id} ->
            # Stripeのチェックアウトセッションを開始する
            create_checkout_session(plan_code, stripe_customer_id, price_id)

          :error ->
            :error
        end

      stripe_customer_id ->
        # TODO: create_checkout_sessionが2回出てきているのでリファクタリングした方が良いかも
        # Stripeのチェックアウトセッションを開始する
        create_checkout_session(plan_code, stripe_customer_id, price_id)
    end
  end

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

  def get_stripe_price_id_by_subscription_plan_code(plan_code, stripe_lookup_key) do
    query =
      from sp in SubscriptionPlan,
        join: stripe_price in StripePrice,
        on: sp.id == stripe_price.subscription_plan_id,
        where:
          sp.plan_code == ^plan_code and stripe_price.stripe_lookup_key == ^stripe_lookup_key,
        select: stripe_price.stripe_price_id

    Repo.one(query)
  end

  def get_stripe_customer_id_by_user_id(user_id) do
    query =
      from usc in UserStripeCustomer,
        where: usc.user_id == ^user_id,
        select: usc.stripe_customer_id

    Repo.one(query)
  end

  def create_checkout_session(plan_code, stripe_customer_id, price_id) do
    encoded_error_message = URI.encode("Failed to complete the contract. Please try again")

    params = %{
      line_items: [
        %{
          price: price_id,
          quantity: 1
        }
      ],
      mode: "subscription",
      success_url: url(~p"/subscription/activate?session_id={CHECKOUT_SESSION_ID}"),
      cancel_url: url(~p"/free_trial?plan=#{plan_code}&error=#{encoded_error_message}"),
      automatic_tax: %{enabled: true},
      customer_update: %{address: "auto"},
      customer: stripe_customer_id
    }

    params
    |> Checkout.create_checkout_session()
  end

  def create_stripe_customer(user_id, user_email) do
    # TODO: Stripe側に作成する前にStripe側に存在確認した方が良い。同じemailでもcreate実行した分だけ顧客がつくられてしまう
    with {:ok, stripe_customer} <- Stripe.Customer.create(%{email: user_email}),
         {:ok, _} <-
           Repo.insert(%UserStripeCustomer{
             user_id: user_id,
             stripe_customer_id: stripe_customer.id
           }) do
      {:ok, stripe_customer.id}
    else
      _ -> :error
    end
  end

  def checkout_session_retrieve(session_id) do
    case Checkout.session_retrieve(session_id) do
      {:ok, session} when session.status == "complete" ->
        Logger.info("Session retrieved and status is complete: #{inspect(session)}")
        {:ok, session}

      {:ok, session} ->
        Logger.error("Session retrieved but status is not complete: #{session.status}")
        {:error, :session_not_complete}

      {:error, reason} ->
        Logger.error("Failed to retrieve session: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def session_retrieve_list_line_items(session_id) do
    case Checkout.session_retrieve_list_line_items(session_id) do
      {:ok, %Stripe.List{data: [%Stripe.Item{price: %Stripe.Price{product: product_id}} | _rest]}} ->
        Logger.info("list line items:: #{inspect(product_id)}")
        {:ok, product_id}

      {:error, reason} ->
        Logger.error("Failed to retrieve list line items: #{inspect(reason)}")
        {:error, reason}
    end
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
