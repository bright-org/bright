defmodule Bright.OnboardingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Onboardings` context.
  """

  @doc """
  Generate a user_onboarding.
  """
  def user_onboarding_fixture(attrs \\ %{}) do
    {:ok, user_onboarding} =
      attrs
      |> Enum.into(%{
        completed_at: ~N[2023-07-14 11:51:00]
      })
      |> Bright.Onboardings.create_user_onboarding()

    user_onboarding
  end
end
