defmodule Bright.JobsTest do
  use Bright.DataCase

  alias Bright.Jobs
  alias Bright.Jobs.Job

  describe "jobs" do
    @invalid_attrs %{name: nil, position: nil}

    test "list_jobs/0 returns all jobs" do
      job = insert(:job)
      assert Jobs.list_jobs() == [job]
    end

    test "get_job!/1 returns the job with given id" do
      job = insert(:job)
      assert Jobs.get_job!(job.id) == job
    end

    test "create_job/1 with valid data creates a job" do
      valid_attrs = %{
        name: "some name",
        position: 42,
        description: "some description",
        rank: :basic
      }

      assert {:ok, %Job{} = job} = Jobs.create_job(valid_attrs)
      assert job.name == "some name"
      assert job.position == 42
    end

    test "create_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
    end

    test "update_job/2 with valid data updates the job" do
      job = insert(:job)
      update_attrs = %{name: "some updated name", position: 43}

      assert {:ok, %Job{} = job} = Jobs.update_job(job, update_attrs)
      assert job.name == "some updated name"
      assert job.position == 43
    end

    test "update_job/2 with invalid data returns error changeset" do
      job = insert(:job)
      assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
      assert job == Jobs.get_job!(job.id)
    end

    test "delete_job/1 deletes the job" do
      job = insert(:job)
      assert {:ok, %Job{}} = Jobs.delete_job(job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
    end

    test "change_job/1 returns a job changeset" do
      job = insert(:job)
      assert %Ecto.Changeset{} = Jobs.change_job(job)
    end

    test "list_job_group_by_career_field_and_rank/0 returns jobs group by career field and rank" do
      job = insert(:job)
      career_field = insert(:career_field)
      skill_panel = insert(:skill_panel)
      insert(:career_field_job, career_field_id: career_field.id, job_id: job.id)
      insert(:job_skill_panel, job_id: job.id, skill_panel_id: skill_panel.id)

      assert %{"engineer" => %{basic: [job]}} ==
               Jobs.list_jobs_group_by_career_field_and_rank()
    end

    test "list_skill_panels_group_by_career_field/1 Returns Job Related SkillPanels group by CareerField" do
      job = insert(:job)
      career_field = insert(:career_field)
      skill_panel = insert(:skill_panel)
      insert(:career_field_job, career_field_id: career_field.id, job_id: job.id)
      insert(:job_skill_panel, job_id: job.id, skill_panel_id: skill_panel.id)

      assert %{career_field => [skill_panel]} ==
               Jobs.list_skill_panels_group_by_career_field(job.id)
    end
  end
end
