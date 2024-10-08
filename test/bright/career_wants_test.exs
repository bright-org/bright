defmodule Bright.CareerWantsTest do
  use Bright.DataCase

  alias Bright.CareerWants
  alias Bright.CareerWants.CareerWant

  describe "career_wants" do
    @invalid_attrs %{name: nil, position: nil}

    test "list_career_wants/0 returns all career_wants" do
      career_want = insert(:career_want)
      assert CareerWants.list_career_wants() == [career_want]
    end

    test "get_career_want!/1 returns the career_want with given id" do
      career_want = insert(:career_want)
      assert CareerWants.get_career_want!(career_want.id) == career_want
    end

    test "create_career_want/1 with valid data creates a career_want" do
      valid_attrs = %{name: "some name", position: 42}

      assert {:ok, %CareerWant{} = career_want} = CareerWants.create_career_want(valid_attrs)
      assert career_want.name == "some name"
      assert career_want.position == 42
    end

    test "create_career_want/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CareerWants.create_career_want(@invalid_attrs)
    end

    test "update_career_want/2 with valid data updates the career_want" do
      career_want = insert(:career_want)
      update_attrs = %{name: "some updated name", position: 43}

      assert {:ok, %CareerWant{} = career_want} =
               CareerWants.update_career_want(career_want, update_attrs)

      assert career_want.name == "some updated name"
      assert career_want.position == 43
    end

    test "update_career_want/2 with invalid data returns error changeset" do
      career_want = insert(:career_want)

      assert {:error, %Ecto.Changeset{}} =
               CareerWants.update_career_want(career_want, @invalid_attrs)

      assert career_want == CareerWants.get_career_want!(career_want.id)
    end

    test "delete_career_want/1 deletes the career_want" do
      career_want = insert(:career_want)
      assert {:ok, %CareerWant{}} = CareerWants.delete_career_want(career_want)
      assert_raise Ecto.NoResultsError, fn -> CareerWants.get_career_want!(career_want.id) end
    end

    test "change_career_want/1 returns a career_want changeset" do
      career_want = insert(:career_want)
      assert %Ecto.Changeset{} = CareerWants.change_career_want(career_want)
    end

    test "list_skill_panels_group_by_career_field/1 returns skill_panels group by career_field" do
      career_want = insert(:career_want)
      job = insert(:job)
      career_field = insert(:career_field)
      skill_panel = insert(:skill_panel)

      insert(:career_field_job, career_field_id: career_field.id, job_id: job.id)
      insert(:career_want_job, career_want_id: career_want.id, job_id: job.id)
      insert(:job_skill_panel, job_id: job.id, skill_panel_id: skill_panel.id)

      assert [{career_field, [skill_panel]}] ==
               CareerWants.list_skill_panels_group_by_career_field(career_want.id)
    end
  end
end
