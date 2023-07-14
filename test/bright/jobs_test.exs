defmodule Bright.JobsTest do
  use Bright.DataCase

  alias Bright.Jobs

  describe "career_fields" do
    alias Bright.Jobs.CareerFields

    import Bright.JobsFixtures

    @invalid_attrs %{background_color: nil, button_color: nil, name: nil, position: nil}

    test "list_career_fields/0 returns all career_fields" do
      career_fields = career_fields_fixture()
      assert Jobs.list_career_fields() == [career_fields]
    end

    test "get_career_fields!/1 returns the career_fields with given id" do
      career_fields = career_fields_fixture()
      assert Jobs.get_career_fields!(career_fields.id) == career_fields
    end

    test "create_career_fields/1 with valid data creates a career_fields" do
      valid_attrs = %{
        background_color: "some background_color",
        button_color: "some button_color",
        name: "some name",
        position: 42
      }

      assert {:ok, %CareerFields{} = career_fields} = Jobs.create_career_fields(valid_attrs)
      assert career_fields.background_color == "some background_color"
      assert career_fields.button_color == "some button_color"
      assert career_fields.name == "some name"
      assert career_fields.position == 42
    end

    test "create_career_fields/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Jobs.create_career_fields(@invalid_attrs)
    end

    test "update_career_fields/2 with valid data updates the career_fields" do
      career_fields = career_fields_fixture()

      update_attrs = %{
        background_color: "some updated background_color",
        button_color: "some updated button_color",
        name: "some updated name",
        position: 43
      }

      assert {:ok, %CareerFields{} = career_fields} =
               Jobs.update_career_fields(career_fields, update_attrs)

      assert career_fields.background_color == "some updated background_color"
      assert career_fields.button_color == "some updated button_color"
      assert career_fields.name == "some updated name"
      assert career_fields.position == 43
    end

    test "update_career_fields/2 with invalid data returns error changeset" do
      career_fields = career_fields_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Jobs.update_career_fields(career_fields, @invalid_attrs)

      assert career_fields == Jobs.get_career_fields!(career_fields.id)
    end

    test "delete_career_fields/1 deletes the career_fields" do
      career_fields = career_fields_fixture()
      assert {:ok, %CareerFields{}} = Jobs.delete_career_fields(career_fields)
      assert_raise Ecto.NoResultsError, fn -> Jobs.get_career_fields!(career_fields.id) end
    end

    test "change_career_fields/1 returns a career_fields changeset" do
      career_fields = career_fields_fixture()
      assert %Ecto.Changeset{} = Jobs.change_career_fields(career_fields)
    end
  end
end
