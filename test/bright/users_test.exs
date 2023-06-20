defmodule Bright.UsersTest do
  use Bright.DataCase

  alias Bright.Users

  describe "bright_users" do
    alias Bright.Users.BrightUser

    import Bright.UsersFixtures

    @invalid_attrs %{password: nil, handle_name: nil, email: nil}

    test "list_bright_users/0 returns all bright_users" do
      bright_user = bright_user_fixture()
      assert Users.list_bright_users() == [bright_user]
    end

    test "get_bright_user!/1 returns the bright_user with given id" do
      bright_user = bright_user_fixture()
      assert Users.get_bright_user!(bright_user.id) == bright_user
    end

    test "create_bright_user/1 with valid data creates a bright_user" do
      valid_attrs = %{password: "some password", handle_name: "some handle_name", email: "some email"}

      assert {:ok, %BrightUser{} = bright_user} = Users.create_bright_user(valid_attrs)
      assert bright_user.password == "some password"
      assert bright_user.handle_name == "some handle_name"
      assert bright_user.email == "some email"
    end

    test "create_bright_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_bright_user(@invalid_attrs)
    end

    test "update_bright_user/2 with valid data updates the bright_user" do
      bright_user = bright_user_fixture()
      update_attrs = %{password: "some updated password", handle_name: "some updated handle_name", email: "some updated email"}

      assert {:ok, %BrightUser{} = bright_user} = Users.update_bright_user(bright_user, update_attrs)
      assert bright_user.password == "some updated password"
      assert bright_user.handle_name == "some updated handle_name"
      assert bright_user.email == "some updated email"
    end

    test "update_bright_user/2 with invalid data returns error changeset" do
      bright_user = bright_user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_bright_user(bright_user, @invalid_attrs)
      assert bright_user == Users.get_bright_user!(bright_user.id)
    end

    test "delete_bright_user/1 deletes the bright_user" do
      bright_user = bright_user_fixture()
      assert {:ok, %BrightUser{}} = Users.delete_bright_user(bright_user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_bright_user!(bright_user.id) end
    end

    test "change_bright_user/1 returns a bright_user changeset" do
      bright_user = bright_user_fixture()
      assert %Ecto.Changeset{} = Users.change_bright_user(bright_user)
    end
  end
end
