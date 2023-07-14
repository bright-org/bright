defmodule Bright.JobsTest do
  use Bright.DataCase

  alias Bright.Jobs

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
end
