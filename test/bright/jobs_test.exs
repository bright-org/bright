defmodule Bright.JobsTest do
  use Bright.DataCase

  alias Bright.Jobs

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
end
