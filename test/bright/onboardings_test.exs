defmodule Bright.OnboardingsTest do
  use Bright.DataCase

  alias Bright.Onboardings
  alias Bright.Onboardings.UserOnboarding

  describe "user_onboardings" do
    @invalid_attrs %{completed_at: nil}

    test "list_user_onboardings/0 returns all user_onboardings" do
      %{id: id} = insert(:user_onboarding)
      assert [%{id: ^id}] = Onboardings.list_user_onboardings()
    end

    test "get_user_onboarding!/1 returns the user_onboarding with given id" do
      %{id: id} = insert(:user_onboarding)
      assert %{id: ^id} = Onboardings.get_user_onboarding!(id)
    end

    test "create_user_onboarding/1 with valid data creates a user_onboarding" do
      valid_attrs = %{completed_at: ~N[2023-07-14 11:51:00], user_id: insert(:user).id}

      assert {:ok, %UserOnboarding{} = user_onboarding} =
               Onboardings.create_user_onboarding(valid_attrs)

      assert user_onboarding.completed_at == ~N[2023-07-14 11:51:00]
    end

    test "create_user_onboarding/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Onboardings.create_user_onboarding(@invalid_attrs)
    end

    test "update_user_onboarding/2 with valid data updates the user_onboarding" do
      user_onboarding = insert(:user_onboarding)
      update_attrs = %{completed_at: ~N[2023-07-15 11:51:00]}

      assert {:ok, %UserOnboarding{} = user_onboarding} =
               Onboardings.update_user_onboarding(user_onboarding, update_attrs)

      assert user_onboarding.completed_at == ~N[2023-07-15 11:51:00]
    end

    test "update_user_onboarding/2 with invalid data returns error changeset" do
      user_onboarding = insert(:user_onboarding)

      assert {:error, %Ecto.Changeset{}} =
               Onboardings.update_user_onboarding(user_onboarding, @invalid_attrs)

      assert user_onboarding.updated_at ==
               Onboardings.get_user_onboarding!(user_onboarding.id).updated_at
    end

    test "delete_user_onboarding/1 deletes the user_onboarding" do
      user_onboarding = insert(:user_onboarding)
      assert {:ok, %UserOnboarding{}} = Onboardings.delete_user_onboarding(user_onboarding)

      assert_raise Ecto.NoResultsError, fn ->
        Onboardings.get_user_onboarding!(user_onboarding.id)
      end
    end

    test "change_user_onboarding/1 returns a user_onboarding changeset" do
      user_onboarding = insert(:user_onboarding)
      assert %Ecto.Changeset{} = Onboardings.change_user_onboarding(user_onboarding)
    end
  end
end
