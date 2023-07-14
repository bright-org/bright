defmodule Bright.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Jobs` context.
  """

  @doc """
  Generate a career_fields.
  """
  def career_fields_fixture(attrs \\ %{}) do
    {:ok, career_fields} =
      attrs
      |> Enum.into(%{
        background_color: "some background_color",
        button_color: "some button_color",
        name: "some name",
        position: 42
      })
      |> Bright.Jobs.create_career_fields()

    career_fields
  end
end
