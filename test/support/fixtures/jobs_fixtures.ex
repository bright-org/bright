defmodule Bright.JobsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Bright.Jobs` context.
  """

  @doc """
  Generate a job.
  """
  def job_fixture(attrs \\ %{}) do
    {:ok, job} =
      attrs
      |> Enum.into(%{
        name: "some name",
        rank: "basic",
        description: "some description",
        position: 42
      })
      |> Bright.Jobs.create_job()

    job
  end

  @doc """
  Generate a career_want_job.
  """
  def career_want_job_fixture(attrs \\ %{}) do
    {:ok, career_want_job} =
      attrs
      |> Enum.into(%{})
      |> Bright.Jobs.create_career_want_job()

    career_want_job
  end

  @doc """
  Generate a job_skill_panel.
  """
  def job_skill_panel_fixture(attrs \\ %{}) do
    {:ok, job_skill_panel} =
      attrs
      |> Enum.into(%{})
      |> Bright.Jobs.create_job_skill_panel()

    job_skill_panel
  end
end
