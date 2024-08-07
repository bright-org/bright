defmodule Bright.StripeTest do
  use Bright.DataCase

  alias Bright.Stripe

  describe "stripe_prices" do
    alias Bright.Stripe.StripePrice

    @invalid_attrs params_for(:stripe_price) |> Map.put(:stripe_price_id, nil)

    test "list_stripe_prices/0 returns all stripe_prices" do
      stripe_price = insert(:stripe_price)
      assert Stripe.list_stripe_prices() == [stripe_price]
    end

    test "get_stripe_price!/1 returns the stripe_price with given id" do
      stripe_price = insert(:stripe_price)
      assert Stripe.get_stripe_price!(stripe_price.id) == stripe_price
    end

    test "create_stripe_price/1 with valid data creates a stripe_price" do
      subscription_plan = insert(:subscription_plans)

      valid_attrs =
        params_for(:stripe_price)
        |> Map.put(:subscription_plan_id, subscription_plan.id)

      assert {:ok, %StripePrice{} = stripe_price} = Stripe.create_stripe_price(valid_attrs)
      assert stripe_price.stripe_price_id == valid_attrs.stripe_price_id
      assert stripe_price.stripe_lookup_key == valid_attrs.stripe_lookup_key
    end

    test "create_stripe_price/1 with invalid data returns error changeset" do
      invalid_attrs =
        params_for(:stripe_price)

      assert {:error, %Ecto.Changeset{}} = Stripe.create_stripe_price(invalid_attrs)
    end

    test "update_stripe_price/2 with valid data updates the stripe_price" do
      stripe_price = insert(:stripe_price)
      subscription_plan = insert(:subscription_plans)

      valid_attrs =
        params_for(:stripe_price)
        |> Map.put(:subscription_plan_id, subscription_plan.id)

      assert {:ok, %StripePrice{} = stripe_price} =
               Stripe.update_stripe_price(stripe_price, valid_attrs)

      assert stripe_price.stripe_price_id == valid_attrs.stripe_price_id
      assert stripe_price.stripe_lookup_key == valid_attrs.stripe_lookup_key
    end

    test "update_stripe_price/2 with invalid data returns error changeset" do
      stripe_price = insert(:stripe_price)

      assert {:error, %Ecto.Changeset{}} =
               Stripe.update_stripe_price(stripe_price, @invalid_attrs)

      assert stripe_price == Stripe.get_stripe_price!(stripe_price.id)
    end

    test "delete_stripe_price/1 deletes the stripe_price" do
      stripe_price = insert(:stripe_price)
      assert {:ok, %StripePrice{}} = Stripe.delete_stripe_price(stripe_price)
      assert_raise Ecto.NoResultsError, fn -> Stripe.get_stripe_price!(stripe_price.id) end
    end

    test "change_stripe_price/1 returns a stripe_price changeset" do
      stripe_price = insert(:stripe_price)
      assert %Ecto.Changeset{} = Stripe.change_stripe_price(stripe_price)
    end
  end
end
