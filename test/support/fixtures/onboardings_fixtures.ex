defmodule Bright.OnboardingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Onboardings` context.
  """

  @doc """
  Generate a user_onboardings.
  """
  def user_onboardings_fixture(attrs \\ %{}) do
    {:ok, user_onboardings} =
      attrs
      |> Enum.into(%{
        completed_at: ~N[2023-07-08 11:20:00]
      })
      |> Bright.Onboardings.create_user_onboardings()

    user_onboardings
  end
end
