defmodule Bright.OnboardingsTest do
  use Bright.DataCase

  alias Bright.Onboardings

  describe "user_onboardings" do
    alias Bright.Onboardings.UserOnboarding

    import Bright.OnboardingsFixtures

    @invalid_attrs %{completed_at: nil}

    test "list_user_onboardings/0 returns all user_onboardings" do
      user_onboarding = user_onboarding_fixture()
      assert Onboardings.list_user_onboardings() == [user_onboarding]
    end

    test "get_user_onboarding!/1 returns the user_onboarding with given id" do
      user_onboarding = user_onboarding_fixture()
      assert Onboardings.get_user_onboarding!(user_onboarding.id) == user_onboarding
    end

    test "create_user_onboarding/1 with valid data creates a user_onboarding" do
      valid_attrs = %{completed_at: ~N[2023-07-14 11:51:00]}

      assert {:ok, %UserOnboarding{} = user_onboarding} =
               Onboardings.create_user_onboarding(valid_attrs)

      assert user_onboarding.completed_at == ~N[2023-07-14 11:51:00]
    end

    test "create_user_onboarding/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Onboardings.create_user_onboarding(@invalid_attrs)
    end

    test "update_user_onboarding/2 with valid data updates the user_onboarding" do
      user_onboarding = user_onboarding_fixture()
      update_attrs = %{completed_at: ~N[2023-07-15 11:51:00]}

      assert {:ok, %UserOnboarding{} = user_onboarding} =
               Onboardings.update_user_onboarding(user_onboarding, update_attrs)

      assert user_onboarding.completed_at == ~N[2023-07-15 11:51:00]
    end

    test "update_user_onboarding/2 with invalid data returns error changeset" do
      user_onboarding = user_onboarding_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Onboardings.update_user_onboarding(user_onboarding, @invalid_attrs)

      assert user_onboarding == Onboardings.get_user_onboarding!(user_onboarding.id)
    end

    test "delete_user_onboarding/1 deletes the user_onboarding" do
      user_onboarding = user_onboarding_fixture()
      assert {:ok, %UserOnboarding{}} = Onboardings.delete_user_onboarding(user_onboarding)

      assert_raise Ecto.NoResultsError, fn ->
        Onboardings.get_user_onboarding!(user_onboarding.id)
      end
    end

    test "change_user_onboarding/1 returns a user_onboarding changeset" do
      user_onboarding = user_onboarding_fixture()
      assert %Ecto.Changeset{} = Onboardings.change_user_onboarding(user_onboarding)
    end
  end

  describe "onboarding_wants" do
    alias Bright.Onboardings.OnboardingWant

    import Bright.OnboardingsFixtures

    @invalid_attrs %{name: nil, position: nil}

    test "list_onboarding_wants/0 returns all onboarding_wants" do
      onboarding_want = onboarding_want_fixture()
      assert Onboardings.list_onboarding_wants() == [onboarding_want]
    end

    test "get_onboarding_want!/1 returns the onboarding_want with given id" do
      onboarding_want = onboarding_want_fixture()
      assert Onboardings.get_onboarding_want!(onboarding_want.id) == onboarding_want
    end

    test "create_onboarding_want/1 with valid data creates a onboarding_want" do
      valid_attrs = %{name: "some name", position: 42}

      assert {:ok, %OnboardingWant{} = onboarding_want} =
               Onboardings.create_onboarding_want(valid_attrs)

      assert onboarding_want.name == "some name"
      assert onboarding_want.position == 42
    end

    test "create_onboarding_want/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Onboardings.create_onboarding_want(@invalid_attrs)
    end

    test "update_onboarding_want/2 with valid data updates the onboarding_want" do
      onboarding_want = onboarding_want_fixture()
      update_attrs = %{name: "some updated name", position: 43}

      assert {:ok, %OnboardingWant{} = onboarding_want} =
               Onboardings.update_onboarding_want(onboarding_want, update_attrs)

      assert onboarding_want.name == "some updated name"
      assert onboarding_want.position == 43
    end

    test "update_onboarding_want/2 with invalid data returns error changeset" do
      onboarding_want = onboarding_want_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Onboardings.update_onboarding_want(onboarding_want, @invalid_attrs)

      assert onboarding_want == Onboardings.get_onboarding_want!(onboarding_want.id)
    end

    test "delete_onboarding_want/1 deletes the onboarding_want" do
      onboarding_want = onboarding_want_fixture()
      assert {:ok, %OnboardingWant{}} = Onboardings.delete_onboarding_want(onboarding_want)

      assert_raise Ecto.NoResultsError, fn ->
        Onboardings.get_onboarding_want!(onboarding_want.id)
      end
    end

    test "change_onboarding_want/1 returns a onboarding_want changeset" do
      onboarding_want = onboarding_want_fixture()
      assert %Ecto.Changeset{} = Onboardings.change_onboarding_want(onboarding_want)
    end
  end
end
