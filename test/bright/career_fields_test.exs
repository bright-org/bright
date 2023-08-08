defmodule Bright.CareerFieldsTest do
  use Bright.DataCase

  alias Bright.CareerFields

  # TODO: Bright.Factoryで対応する
  describe "career_fields" do
    alias Bright.CareerFields.CareerField

    import Bright.JobsFixtures

    @invalid_attrs %{name_en: nil, name_ja: nil, position: nil}

    test "list_career_fields/0 returns all career_fields" do
      career_field = career_field_fixture()
      assert CareerFields.list_career_fields() == [career_field]
    end

    test "get_career_field!/1 returns the career_field with given id" do
      career_field = career_field_fixture()
      assert CareerFields.get_career_field!(career_field.id) == career_field
    end

    test "create_career_field/1 with valid data creates a career_field" do
      valid_attrs = %{
        name_en: "some name",
        name_ja: "日本語名",
        position: 42
      }

      assert {:ok, %CareerField{} = career_field} = CareerFields.create_career_field(valid_attrs)
      assert career_field.name_en == "some name"
      assert career_field.name_ja == "日本語名"
      assert career_field.position == 42
    end

    test "create_career_field/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CareerFields.create_career_field(@invalid_attrs)
    end

    test "update_career_field/2 with valid data updates the career_field" do
      career_field = career_field_fixture()

      update_attrs = %{
        name_en: "some updated name",
        name_ja: "更新された日本語名",
        position: 43
      }

      assert {:ok, %CareerField{} = career_field} =
               CareerFields.update_career_field(career_field, update_attrs)

      assert career_field.name_en == "some updated name"
      assert career_field.name_ja == "更新された日本語名"
      assert career_field.position == 43
    end

    test "update_career_field/2 with invalid data returns error changeset" do
      career_field = career_field_fixture()

      assert {:error, %Ecto.Changeset{}} =
               CareerFields.update_career_field(career_field, @invalid_attrs)

      assert career_field == CareerFields.get_career_field!(career_field.id)
    end

    test "delete_career_field/1 deletes the career_field" do
      career_field = career_field_fixture()
      assert {:ok, %CareerField{}} = CareerFields.delete_career_field(career_field)
      assert_raise Ecto.NoResultsError, fn -> CareerFields.get_career_field!(career_field.id) end
    end

    test "change_career_field/1 returns a career_field changeset" do
      career_field = career_field_fixture()
      assert %Ecto.Changeset{} = CareerFields.change_career_field(career_field)
    end
  end
end
