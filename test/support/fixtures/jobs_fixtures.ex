defmodule Bright.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Jobs` context.
  """

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

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        name: "some name",
        position: 42
      })
      |> Bright.Jobs.create_job()

    job
  end
end
