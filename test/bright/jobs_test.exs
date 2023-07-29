defmodule Bright.JobsTest do
  use Bright.DataCase

  alias Bright.Jobs

  # TODO: Factoryで対応する
  describe "career_wants" do
    alias Bright.Jobs.CareerWant

    import Bright.JobsFixtures

    @invalid_attrs %{name: nil, position: nil}

    test "list_career_wants/0 returns all career_wants" do
      career_want = career_want_fixture()
      assert Jobs.list_career_wants() == [career_want]
    end

    test "get_career_want!/1 returns the career_want with given id" do
      career_want = career_want_fixture()
      assert Jobs.get_career_want!(career_want.id) == career_want
    end

    test "create_career_want/1 with valid data creates a career_want" do
      valid_attrs = %{name: "some name", position: 42}

      assert {:ok, %CareerWant{} = career_want} = Jobs.create_career_want(valid_attrs)
      assert career_want.name == "some name"
      assert career_want.position == 42
    end

    test "create_career_want/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_career_want(@invalid_attrs)
    end

    test "update_career_want/2 with valid data updates the career_want" do
      career_want = career_want_fixture()
      update_attrs = %{name: "some updated name", position: 43}

      assert {:ok, %CareerWant{} = career_want} =
               Jobs.update_career_want(career_want, update_attrs)

      assert career_want.name == "some updated name"
      assert career_want.position == 43
    end

    test "update_career_want/2 with invalid data returns error changeset" do
      career_want = career_want_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_career_want(career_want, @invalid_attrs)
      assert career_want == Jobs.get_career_want!(career_want.id)
    end

    test "delete_career_want/1 deletes the career_want" do
      career_want = career_want_fixture()
      assert {:ok, %CareerWant{}} = Jobs.delete_career_want(career_want)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_career_want!(career_want.id) end
    end

    test "change_career_want/1 returns a career_want changeset" do
      career_want = career_want_fixture()
      assert %Ecto.Changeset{} = Jobs.change_career_want(career_want)
    end
  end

  # TODO: Bright.Factoryで対応する
  describe "career_fields" do
    alias Bright.Jobs.CareerField

    import Bright.JobsFixtures

    @invalid_attrs %{background_color: nil, button_color: nil, name: nil, position: nil}

    test "list_career_fields/0 returns all career_fields" do
      career_field = career_field_fixture()
      assert Jobs.list_career_fields() == [career_field]
    end

    test "get_career_field!/1 returns the career_field with given id" do
      career_field = career_field_fixture()
      assert Jobs.get_career_field!(career_field.id) == career_field
    end

    test "create_career_field/1 with valid data creates a career_field" do
      valid_attrs = %{
        background_color: "some background_color",
        button_color: "some button_color",
        name: "some name",
        position: 42
      }

      assert {:ok, %CareerField{} = career_field} = Jobs.create_career_field(valid_attrs)
      assert career_field.background_color == "some background_color"
      assert career_field.button_color == "some button_color"
      assert career_field.name == "some name"
      assert career_field.position == 42
    end

    test "create_career_field/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_career_field(@invalid_attrs)
    end

    test "update_career_field/2 with valid data updates the career_field" do
      career_field = career_field_fixture()

      update_attrs = %{
        background_color: "some updated background_color",
        button_color: "some updated button_color",
        name: "some updated name",
        position: 43
      }

      assert {:ok, %CareerField{} = career_field} =
               Jobs.update_career_field(career_field, update_attrs)

      assert career_field.background_color == "some updated background_color"
      assert career_field.button_color == "some updated button_color"
      assert career_field.name == "some updated name"
      assert career_field.position == 43
    end

    test "update_career_field/2 with invalid data returns error changeset" do
      career_field = career_field_fixture()
      assert {:error, %Ecto.Changeset{}} = Jobs.update_career_field(career_field, @invalid_attrs)
      assert career_field == Jobs.get_career_field!(career_field.id)
    end

    test "delete_career_field/1 deletes the career_field" do
      career_field = career_field_fixture()
      assert {:ok, %CareerField{}} = Jobs.delete_career_field(career_field)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_career_field!(career_field.id) end
    end

    test "change_career_field/1 returns a career_field changeset" do
      career_field = career_field_fixture()
      assert %Ecto.Changeset{} = Jobs.change_career_field(career_field)
    end
  end

  # TODO: Factoryで対応する
  # describe "jobs" do
  #   alias Bright.Jobs.Job

  #   import Bright.JobsFixtures

  #   @invalid_attrs %{name: nil, position: nil}

  #   test "list_jobs/0 returns all jobs" do
  #     job = job_fixture()
  #     assert Jobs.list_jobs() == [job]
  #   end

  #   test "get_job!/1 returns the job with given id" do
  #     job = job_fixture()
  #     assert Jobs.get_job!(job.id) == job
  #   end

  #   test "create_job/1 with valid data creates a job" do
  #     valid_attrs = %{name: "some name", position: 42}

  #     assert {:ok, %Job{} = job} = Jobs.create_job(valid_attrs)
  #     assert job.name == "some name"
  #     assert job.position == 42
  #   end

  #   test "create_job/1 with invalid data returns error changeset" do
  #     assert {:error, %Ecto.Changeset{}} = Jobs.create_job(@invalid_attrs)
  #   end

  #   test "update_job/2 with valid data updates the job" do
  #     job = job_fixture()
  #     update_attrs = %{name: "some updated name", position: 43}

  #     assert {:ok, %Job{} = job} = Jobs.update_job(job, update_attrs)
  #     assert job.name == "some updated name"
  #     assert job.position == 43
  #   end

  #   test "update_job/2 with invalid data returns error changeset" do
  #     job = job_fixture()
  #     assert {:error, %Ecto.Changeset{}} = Jobs.update_job(job, @invalid_attrs)
  #     assert job == Jobs.get_job!(job.id)
  #   end

  #   test "delete_job/1 deletes the job" do
  #     job = job_fixture()
  #     assert {:ok, %Job{}} = Jobs.delete_job(job)
  #     assert_raise Ecto.NoResultsError, fn -> Jobs.get_job!(job.id) end
  #   end

  #   test "change_job/1 returns a job changeset" do
  #     job = job_fixture()
  #     assert %Ecto.Changeset{} = Jobs.change_job(job)
  #   end
  # end

  describe "career_want_jobs" do
    alias Bright.Jobs.CareerWantJob

    import Bright.JobsFixtures

    @invalid_attrs %{}

    test "list_career_want_jobs/0 returns all career_want_jobs" do
      career_want_job = career_want_job_fixture()
      assert Jobs.list_career_want_jobs() == [career_want_job]
    end

    test "get_career_want_job!/1 returns the career_want_job with given id" do
      career_want_job = career_want_job_fixture()
      assert Jobs.get_career_want_job!(career_want_job.id) == career_want_job
    end

    test "create_career_want_job/1 with valid data creates a career_want_job" do
      valid_attrs = %{}

      assert {:ok, %CareerWantJob{} = career_want_job} = Jobs.create_career_want_job(valid_attrs)
    end

    test "create_career_want_job/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_career_want_job(@invalid_attrs)
    end

    test "update_career_want_job/2 with valid data updates the career_want_job" do
      career_want_job = career_want_job_fixture()
      update_attrs = %{}

      assert {:ok, %CareerWantJob{} = career_want_job} =
               Jobs.update_career_want_job(career_want_job, update_attrs)
    end

    test "update_career_want_job/2 with invalid data returns error changeset" do
      career_want_job = career_want_job_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Jobs.update_career_want_job(career_want_job, @invalid_attrs)

      assert career_want_job == Jobs.get_career_want_job!(career_want_job.id)
    end

    test "delete_career_want_job/1 deletes the career_want_job" do
      career_want_job = career_want_job_fixture()
      assert {:ok, %CareerWantJob{}} = Jobs.delete_career_want_job(career_want_job)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_career_want_job!(career_want_job.id) end
    end

    test "change_career_want_job/1 returns a career_want_job changeset" do
      career_want_job = career_want_job_fixture()
      assert %Ecto.Changeset{} = Jobs.change_career_want_job(career_want_job)
    end
  end
end
