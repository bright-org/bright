defmodule Bright.StripeTest do
  use Bright.DataCase

  alias Bright.Stripe

  describe "stripe_prices" do
    alias Bright.Stripe.StripePrice

    import Bright.StripeFixtures

    @invalid_attrs %{stripe_price_id: nil, stripe_lookup_key: nil}

    test "list_stripe_prices/0 returns all stripe_prices" do
      stripe_price = stripe_price_fixture()
      assert Stripe.list_stripe_prices() == [stripe_price]
    end

    test "get_stripe_price!/1 returns the stripe_price with given id" do
      stripe_price = stripe_price_fixture()
      assert Stripe.get_stripe_price!(stripe_price.id) == stripe_price
    end

    test "create_stripe_price/1 with valid data creates a stripe_price" do
      valid_attrs = %{stripe_price_id: "some stripe_price_id", stripe_lookup_key: "some stripe_lookup_key"}

      assert {:ok, %StripePrice{} = stripe_price} = Stripe.create_stripe_price(valid_attrs)
      assert stripe_price.stripe_price_id == "some stripe_price_id"
      assert stripe_price.stripe_lookup_key == "some stripe_lookup_key"
    end

    test "create_stripe_price/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stripe.create_stripe_price(@invalid_attrs)
    end

    test "update_stripe_price/2 with valid data updates the stripe_price" do
      stripe_price = stripe_price_fixture()
      update_attrs = %{stripe_price_id: "some updated stripe_price_id", stripe_lookup_key: "some updated stripe_lookup_key"}

      assert {:ok, %StripePrice{} = stripe_price} = Stripe.update_stripe_price(stripe_price, update_attrs)
      assert stripe_price.stripe_price_id == "some updated stripe_price_id"
      assert stripe_price.stripe_lookup_key == "some updated stripe_lookup_key"
    end

    test "update_stripe_price/2 with invalid data returns error changeset" do
      stripe_price = stripe_price_fixture()
      assert {:error, %Ecto.Changeset{}} = Stripe.update_stripe_price(stripe_price, @invalid_attrs)
      assert stripe_price == Stripe.get_stripe_price!(stripe_price.id)
    end

    test "delete_stripe_price/1 deletes the stripe_price" do
      stripe_price = stripe_price_fixture()
      assert {:ok, %StripePrice{}} = Stripe.delete_stripe_price(stripe_price)
      assert_raise Ecto.NoResultsError, fn -> Stripe.get_stripe_price!(stripe_price.id) end
    end

    test "change_stripe_price/1 returns a stripe_price changeset" do
      stripe_price = stripe_price_fixture()
      assert %Ecto.Changeset{} = Stripe.change_stripe_price(stripe_price)
    end
  end
end
