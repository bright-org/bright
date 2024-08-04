defmodule BrightWeb.Admin.StripePriceLiveTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  @create_attrs params_for(:stripe_price)
  @update_attrs params_for(:stripe_price)
  @invalid_attrs %{stripe_price_id: nil}

  defp create_stripe_price(_) do
    stripe_price = insert(:stripe_price)

    %{stripe_price: stripe_price}
  end

  describe "Index" do
    setup [:create_stripe_price]

    test "lists all stripe_prices", %{conn: conn, stripe_price: stripe_price} do
      {:ok, _index_live, html} = live(conn, ~p"/admin/stripe_prices")

      assert html =~ "Listing Stripe prices"
      assert html =~ stripe_price.stripe_price_id
    end

    test "saves new stripe_price", %{conn: conn, stripe_price: stripe_price} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/stripe_prices")

      valid_attrs =
        @create_attrs
        |> Map.put(:subscription_plan_id, stripe_price.subscription_plan_id)

      assert index_live |> element("a", "New Stripe price") |> render_click() =~
               "New Stripe price"

      assert_patch(index_live, ~p"/admin/stripe_prices/new")

      assert index_live
             |> form("#stripe_price-form", stripe_price: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#stripe_price-form", stripe_price: valid_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/stripe_prices")

      html = render(index_live)
      assert html =~ "Stripe price created successfully"
      assert html =~ valid_attrs.stripe_price_id
    end

    test "updates stripe_price in listing", %{conn: conn, stripe_price: stripe_price} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/stripe_prices")

      assert index_live
             |> element("#stripe_prices-#{stripe_price.id} a", "Edit")
             |> render_click() =~
               "Edit Stripe price"

      assert_patch(index_live, ~p"/admin/stripe_prices/#{stripe_price}/edit")

      assert index_live
             |> form("#stripe_price-form", stripe_price: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert index_live
             |> form("#stripe_price-form", stripe_price: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/admin/stripe_prices")

      html = render(index_live)
      assert html =~ "Stripe price updated successfully"
      assert html =~ @update_attrs.stripe_price_id
    end

    test "deletes stripe_price in listing", %{conn: conn, stripe_price: stripe_price} do
      {:ok, index_live, _html} = live(conn, ~p"/admin/stripe_prices")

      assert index_live
             |> element("#stripe_prices-#{stripe_price.id} a", "Delete")
             |> render_click()

      refute has_element?(index_live, "#stripe_prices-#{stripe_price.id}")
    end
  end

  describe "Show" do
    setup [:create_stripe_price]

    test "displays stripe_price", %{conn: conn, stripe_price: stripe_price} do
      {:ok, _show_live, html} = live(conn, ~p"/admin/stripe_prices/#{stripe_price}")

      assert html =~ "Show Stripe price"
      assert html =~ stripe_price.stripe_price_id
    end

    test "updates stripe_price within modal", %{conn: conn, stripe_price: stripe_price} do
      {:ok, show_live, _html} = live(conn, ~p"/admin/stripe_prices/#{stripe_price}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Stripe price"

      assert_patch(show_live, ~p"/admin/stripe_prices/#{stripe_price}/show/edit")

      assert show_live
             |> form("#stripe_price-form", stripe_price: @invalid_attrs)
             |> render_change() =~ "入力してください"

      assert show_live
             |> form("#stripe_price-form", stripe_price: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/admin/stripe_prices/#{stripe_price}")

      html = render(show_live)
      assert html =~ "Stripe price updated successfully"
      assert html =~ @update_attrs.stripe_price_id
    end
  end
end
