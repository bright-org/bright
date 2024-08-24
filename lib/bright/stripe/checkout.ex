defmodule Bright.Stripe.Checkout do
  @moduledoc """
  Handles Stripe Checkout sessions.
  """

  require Logger

  alias Stripe.Checkout.Session

  def create_checkout_session(params) do
    # 実際にSession.createを呼び出す
    case Session.create(params) do
      {:ok, session} ->
        Logger.info("Checkout session created successfully: #{inspect(session)}")
        {:ok, session}

      {:error, reason} ->
        Logger.error("Failed to create checkout session: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def session_retrieve(session_id) do
    case Session.retrieve(session_id) do
      {:ok, session} ->
        Logger.info("Session retrieve successfully: #{inspect(session)}")
        {:ok, session}

      {:error, reason} ->
        Logger.error("Failed to session retrieve: #{inspect(reason)}")
        {:error, reason}
    end
  end

  def session_retrieve_list_line_items(session_id) do
    case Session.list_line_items(session_id) do
      {:ok, items} ->
        Logger.info("Session retrieve successfully: #{inspect(items)}")
        {:ok, items}

      {:error, reason} ->
        Logger.error("Failed to session retrieve: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
