defmodule Bright.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Jobs` context.
  """

  @doc """
  Generate a career_want.
  """
  def career_want_fixture(attrs \\ %{}) do
    {:ok, career_want} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: 42
      })
      |> Bright.Jobs.create_career_want()

    career_want
  end

  @doc """
  Generate a career_field.
  """
  def career_field_fixture(attrs \\ %{}) do
    {:ok, career_field} =
      attrs
      |> Enum.into(%{
        background_color: "some background_color",
        button_color: "some button_color",
        name: "some name",
        position: 42
      })
      |> Bright.Jobs.create_career_field()

    career_field
  end
end
