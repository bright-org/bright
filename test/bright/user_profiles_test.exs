defmodule Bright.UserProfilesTest do
  use Bright.DataCase

  alias Bright.UserProfiles

  import Bright.Factory

  describe "user_profiles" do
    alias Bright.UserProfiles.UserProfile

    @invalid_attrs %{
      title: nil,
      user_id: nil,
      detail: nil,
      icon_file_path: nil,
      twitter_url: nil,
      facebook_url: nil,
      github_url: nil
    }

    test "list_user_profiles/0 returns all user_profiles" do
      user_profile = insert(:user_profile)
      assert UserProfiles.list_user_profiles() == [user_profile]
    end

    test "get_user_profile!/1 returns the user_profile with given id" do
      user_profile = insert(:user_profile)
      assert UserProfiles.get_user_profile!(user_profile.id) == user_profile
    end

    test "create_user_profile/1 with valid data creates a user_profile" do
      user = insert(:user)

      valid_attrs = %{
        title: "some title",
        user_id: user.id,
        detail: "some detail",
        icon_file_path: "some icon_file_path",
        twitter_url: "some twitter_url",
        facebook_url: "some facebook_url",
        github_url: "some github_url"
      }

      assert {:ok, %UserProfile{} = user_profile} = UserProfiles.create_user_profile(valid_attrs)
      assert user_profile.title == "some title"
      assert user_profile.user_id == user.id
      assert user_profile.detail == "some detail"
      assert user_profile.icon_file_path == "some icon_file_path"
      assert user_profile.twitter_url == "some twitter_url"
      assert user_profile.facebook_url == "some facebook_url"
      assert user_profile.github_url == "some github_url"
    end

    test "create_user_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserProfiles.create_user_profile(@invalid_attrs)
    end

    test "update_user_profile/2 with valid data updates the user_profile" do
      user_profile = insert(:user_profile)
      user = insert(:user)

      update_attrs = %{
        title: "some updated title",
        user_id: user.id,
        detail: "some updated detail",
        icon_file_path: "some updated icon_file_path",
        twitter_url: "some updated twitter_url",
        facebook_url: "some updated facebook_url",
        github_url: "some updated github_url"
      }

      assert {:ok, %UserProfile{} = user_profile} =
               UserProfiles.update_user_profile(user_profile, update_attrs)

      assert user_profile.title == "some updated title"
      assert user_profile.user_id == user.id
      assert user_profile.detail == "some updated detail"
      assert user_profile.icon_file_path == "some updated icon_file_path"
      assert user_profile.twitter_url == "some updated twitter_url"
      assert user_profile.facebook_url == "some updated facebook_url"
      assert user_profile.github_url == "some updated github_url"
    end

    test "update_user_profile/2 with invalid data returns error changeset" do
      user_profile = insert(:user_profile)

      assert {:error, %Ecto.Changeset{}} =
               UserProfiles.update_user_profile(user_profile, @invalid_attrs)

      assert user_profile == UserProfiles.get_user_profile!(user_profile.id)
    end

    test "delete_user_profile/1 deletes the user_profile" do
      user_profile = insert(:user_profile)
      assert {:ok, %UserProfile{}} = UserProfiles.delete_user_profile(user_profile)
      assert_raise Ecto.NoResultsError, fn -> UserProfiles.get_user_profile!(user_profile.id) end
    end

    test "change_user_profile/1 returns a user_profile changeset" do
      user_profile = insert(:user_profile)
      assert %Ecto.Changeset{} = UserProfiles.change_user_profile(user_profile)
    end

    test "get_user_profile_by_name/1 returns a user_profile" do
      user_profile = insert(:user_profile)
      assert UserProfiles.get_user_profile_by_name(user_profile.user.name) == user_profile
    end
  end
end
