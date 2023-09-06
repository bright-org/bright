defmodule Bright.TalentedPersonsTest do
  use Bright.DataCase

  alias Bright.TalentedPersons

  describe "talented_persons" do
    # alias Bright.TalentedPersons.TalentedPerson
    import Bright.Factory

    # @invalid_attrs %{introducer_user_id: nil, fave_user_id: nil, team_id: nil, fave_point: nil}

    test "list_talented_persons/0 returns all talented_persons" do
      talented_person = insert(:talented_person)

      assert TalentedPersons.list_talented_persons()
             |> Repo.preload([:introducer_user, :fave_user, :team]) == [talented_person]
    end

    # test "get_talented_person!/1 returns the talented_person with given id" do
    #   talented_person = talented_person_fixture()
    #   assert TalentedPersons.get_talented_person!(talented_person.id) == talented_person
    # end

    # test "create_talented_person/1 with valid data creates a talented_person" do
    #   valid_attrs = %{introducer_user_id: "7488a646-e31f-11e4-aace-600308960662", fave_user_id: "7488a646-e31f-11e4-aace-600308960662", team_id: "7488a646-e31f-11e4-aace-600308960662", fave_point: "some fave_point"}

    #   assert {:ok, %TalentedPerson{} = talented_person} = TalentedPersons.create_talented_person(valid_attrs)
    #   assert talented_person.introducer_user_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert talented_person.fave_user_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert talented_person.team_id == "7488a646-e31f-11e4-aace-600308960662"
    #   assert talented_person.fave_point == "some fave_point"
    # end

    # test "create_talented_person/1 with invalid data returns error changeset" do
    #   assert {:error, %Ecto.Changeset{}} = TalentedPersons.create_talented_person(@invalid_attrs)
    # end

    # test "update_talented_person/2 with valid data updates the talented_person" do
    #   talented_person = talented_person_fixture()
    #   update_attrs = %{introducer_user_id: "7488a646-e31f-11e4-aace-600308960668", fave_user_id: "7488a646-e31f-11e4-aace-600308960668", team_id: "7488a646-e31f-11e4-aace-600308960668", fave_point: "some updated fave_point"}

    #   assert {:ok, %TalentedPerson{} = talented_person} = TalentedPersons.update_talented_person(talented_person, update_attrs)
    #   assert talented_person.introducer_user_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert talented_person.fave_user_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert talented_person.team_id == "7488a646-e31f-11e4-aace-600308960668"
    #   assert talented_person.fave_point == "some updated fave_point"
    # end

    # test "update_talented_person/2 with invalid data returns error changeset" do
    #   talented_person = talented_person_fixture()
    #   assert {:error, %Ecto.Changeset{}} = TalentedPersons.update_talented_person(talented_person, @invalid_attrs)
    #   assert talented_person == TalentedPersons.get_talented_person!(talented_person.id)
    # end

    # test "delete_talented_person/1 deletes the talented_person" do
    #   talented_person = talented_person_fixture()
    #   assert {:ok, %TalentedPerson{}} = TalentedPersons.delete_talented_person(talented_person)
    #   assert_raise Ecto.NoResultsError, fn -> TalentedPersons.get_talented_person!(talented_person.id) end
    # end

    # test "change_talented_person/1 returns a talented_person changeset" do
    #   talented_person = talented_person_fixture()
    #   assert %Ecto.Changeset{} = TalentedPersons.change_talented_person(talented_person)
    # end
  end
end
