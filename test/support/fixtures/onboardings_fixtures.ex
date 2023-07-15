defmodule Bright.OnboardingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Onboardings` context.
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

  @doc """
  Generate a onboarding_want.
  """
  def onboarding_want_fixture(attrs \\ %{}) do
    {:ok, onboarding_want} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: 42
      })
      |> Bright.Onboardings.create_onboarding_want()

    onboarding_want
  end
end
