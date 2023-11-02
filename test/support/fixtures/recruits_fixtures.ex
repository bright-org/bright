defmodule Bright.RecruitsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Recruits` context.
  """

  @doc """
  Generate a interview.
  """
  def interview_fixture(attrs \\ %{}) do
    {:ok, interview} =
      attrs
      |> Enum.into(%{
        skill_params: "some skill_params",
        status: "some status",
        comment: "some comment"
      })
      |> Bright.Recruits.create_interview()

    interview
  end
end
