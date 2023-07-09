defmodule Bright.OnboardingsTest do
  use Bright.DataCase

  alias Bright.Onboardings

  describe "user_onboardings" do
    alias Bright.Onboardings.UserOnboardings

    import Bright.OnboardingsFixtures

    @invalid_attrs %{completed_at: nil}

    test "list_user_onboardings/0 returns all user_onboardings" do
      user_onboardings = user_onboardings_fixture()
      assert Onboardings.list_user_onboardings() == [user_onboardings]
    end

    test "get_user_onboardings!/1 returns the user_onboardings with given id" do
      user_onboardings = user_onboardings_fixture()
      assert Onboardings.get_user_onboardings!(user_onboardings.id) == user_onboardings
    end

    test "create_user_onboardings/1 with valid data creates a user_onboardings" do
      valid_attrs = %{completed_at: ~N[2023-07-08 11:20:00]}

      assert {:ok, %UserOnboardings{} = user_onboardings} = Onboardings.create_user_onboardings(valid_attrs)
      assert user_onboardings.completed_at == ~N[2023-07-08 11:20:00]
    end

    test "create_user_onboardings/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Onboardings.create_user_onboardings(@invalid_attrs)
    end

    test "update_user_onboardings/2 with valid data updates the user_onboardings" do
      user_onboardings = user_onboardings_fixture()
      update_attrs = %{completed_at: ~N[2023-07-09 11:20:00]}

      assert {:ok, %UserOnboardings{} = user_onboardings} = Onboardings.update_user_onboardings(user_onboardings, update_attrs)
      assert user_onboardings.completed_at == ~N[2023-07-09 11:20:00]
    end

    test "update_user_onboardings/2 with invalid data returns error changeset" do
      user_onboardings = user_onboardings_fixture()
      assert {:error, %Ecto.Changeset{}} = Onboardings.update_user_onboardings(user_onboardings, @invalid_attrs)
      assert user_onboardings == Onboardings.get_user_onboardings!(user_onboardings.id)
    end

    test "delete_user_onboardings/1 deletes the user_onboardings" do
      user_onboardings = user_onboardings_fixture()
      assert {:ok, %UserOnboardings{}} = Onboardings.delete_user_onboardings(user_onboardings)
      assert_raise Ecto.NoResultsError, fn -> Onboardings.get_user_onboardings!(user_onboardings.id) end
    end

    test "change_user_onboardings/1 returns a user_onboardings changeset" do
      user_onboardings = user_onboardings_fixture()
      assert %Ecto.Changeset{} = Onboardings.change_user_onboardings(user_onboardings)
    end
  end
end
