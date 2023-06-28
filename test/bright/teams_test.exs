defmodule Bright.TeamsTest do
  use Bright.DataCase

  alias Bright.Teams

  describe "teams" do
    alias Bright.Teams.Team

    import Bright.TeamsFixtures

    @invalid_attrs %{team_name: nil, enable_hr_functions: nil, auther_bright_user_id: nil}

    test "list_teams/0 returns all teams" do
      team = team_fixture()
      assert Teams.list_teams() == [team]
    end

    test "get_team!/1 returns the team with given id" do
      team = team_fixture()
      assert Teams.get_team!(team.id) == team
    end

    test "create_team/1 with valid data creates a team" do
      valid_attrs = %{team_name: "some team_name", enable_hr_functions: true, auther_bright_user_id: 42}

      assert {:ok, %Team{} = team} = Teams.create_team(valid_attrs)
      assert team.team_name == "some team_name"
      assert team.enable_hr_functions == true
      assert team.auther_bright_user_id == 42
    end

    test "create_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team(@invalid_attrs)
    end

    test "update_team/2 with valid data updates the team" do
      team = team_fixture()
      update_attrs = %{team_name: "some updated team_name", enable_hr_functions: false, auther_bright_user_id: 43}

      assert {:ok, %Team{} = team} = Teams.update_team(team, update_attrs)
      assert team.team_name == "some updated team_name"
      assert team.enable_hr_functions == false
      assert team.auther_bright_user_id == 43
    end

    test "update_team/2 with invalid data returns error changeset" do
      team = team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team(team, @invalid_attrs)
      assert team == Teams.get_team!(team.id)
    end

    test "delete_team/1 deletes the team" do
      team = team_fixture()
      assert {:ok, %Team{}} = Teams.delete_team(team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team!(team.id) end
    end

    test "change_team/1 returns a team changeset" do
      team = team_fixture()
      assert %Ecto.Changeset{} = Teams.change_team(team)
    end
  end

  describe "user_joined_teams" do
    alias Bright.Teams.UserJoinedTeam

    import Bright.TeamsFixtures

    @invalid_attrs %{bright_user_id: nil, team_id: nil, is_auther: nil, is_primary_team: nil}

    test "list_user_joined_teams/0 returns all user_joined_teams" do
      user_joined_team = user_joined_team_fixture()
      assert Teams.list_user_joined_teams() == [user_joined_team]
    end

    test "get_user_joined_team!/1 returns the user_joined_team with given id" do
      user_joined_team = user_joined_team_fixture()
      assert Teams.get_user_joined_team!(user_joined_team.id) == user_joined_team
    end

    test "create_user_joined_team/1 with valid data creates a user_joined_team" do
      valid_attrs = %{bright_user_id: 42, team_id: 42, is_auther: true, is_primary_team: true}

      assert {:ok, %UserJoinedTeam{} = user_joined_team} = Teams.create_user_joined_team(valid_attrs)
      assert user_joined_team.bright_user_id == 42
      assert user_joined_team.team_id == 42
      assert user_joined_team.is_auther == true
      assert user_joined_team.is_primary_team == true
    end

    test "create_user_joined_team/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_user_joined_team(@invalid_attrs)
    end

    test "update_user_joined_team/2 with valid data updates the user_joined_team" do
      user_joined_team = user_joined_team_fixture()
      update_attrs = %{bright_user_id: 43, team_id: 43, is_auther: false, is_primary_team: false}

      assert {:ok, %UserJoinedTeam{} = user_joined_team} = Teams.update_user_joined_team(user_joined_team, update_attrs)
      assert user_joined_team.bright_user_id == 43
      assert user_joined_team.team_id == 43
      assert user_joined_team.is_auther == false
      assert user_joined_team.is_primary_team == false
    end

    test "update_user_joined_team/2 with invalid data returns error changeset" do
      user_joined_team = user_joined_team_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_user_joined_team(user_joined_team, @invalid_attrs)
      assert user_joined_team == Teams.get_user_joined_team!(user_joined_team.id)
    end

    test "delete_user_joined_team/1 deletes the user_joined_team" do
      user_joined_team = user_joined_team_fixture()
      assert {:ok, %UserJoinedTeam{}} = Teams.delete_user_joined_team(user_joined_team)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_user_joined_team!(user_joined_team.id) end
    end

    test "change_user_joined_team/1 returns a user_joined_team changeset" do
      user_joined_team = user_joined_team_fixture()
      assert %Ecto.Changeset{} = Teams.change_user_joined_team(user_joined_team)
    end
  end

  describe "team_member_users" do
    alias Bright.Teams.TeamMemberUsers

    import Bright.TeamsFixtures

    @invalid_attrs %{is_admin: nil, is_primary: nil, team_id: nil, user_id: nil}

    test "list_team_member_users/0 returns all team_member_users" do
      team_member_users = team_member_users_fixture()
      assert Teams.list_team_member_users() == [team_member_users]
    end

    test "get_team_member_users!/1 returns the team_member_users with given id" do
      team_member_users = team_member_users_fixture()
      assert Teams.get_team_member_users!(team_member_users.id) == team_member_users
    end

    test "create_team_member_users/1 with valid data creates a team_member_users" do
      valid_attrs = %{is_admin: true, is_primary: true, team_id: "7488a646-e31f-11e4-aace-600308960662", user_id: "7488a646-e31f-11e4-aace-600308960662"}

      assert {:ok, %TeamMemberUsers{} = team_member_users} = Teams.create_team_member_users(valid_attrs)
      assert team_member_users.is_admin == true
      assert team_member_users.is_primary == true
      assert team_member_users.team_id == "7488a646-e31f-11e4-aace-600308960662"
      assert team_member_users.user_id == "7488a646-e31f-11e4-aace-600308960662"
    end

    test "create_team_member_users/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Teams.create_team_member_users(@invalid_attrs)
    end

    test "update_team_member_users/2 with valid data updates the team_member_users" do
      team_member_users = team_member_users_fixture()
      update_attrs = %{is_admin: false, is_primary: false, team_id: "7488a646-e31f-11e4-aace-600308960668", user_id: "7488a646-e31f-11e4-aace-600308960668"}

      assert {:ok, %TeamMemberUsers{} = team_member_users} = Teams.update_team_member_users(team_member_users, update_attrs)
      assert team_member_users.is_admin == false
      assert team_member_users.is_primary == false
      assert team_member_users.team_id == "7488a646-e31f-11e4-aace-600308960668"
      assert team_member_users.user_id == "7488a646-e31f-11e4-aace-600308960668"
    end

    test "update_team_member_users/2 with invalid data returns error changeset" do
      team_member_users = team_member_users_fixture()
      assert {:error, %Ecto.Changeset{}} = Teams.update_team_member_users(team_member_users, @invalid_attrs)
      assert team_member_users == Teams.get_team_member_users!(team_member_users.id)
    end

    test "delete_team_member_users/1 deletes the team_member_users" do
      team_member_users = team_member_users_fixture()
      assert {:ok, %TeamMemberUsers{}} = Teams.delete_team_member_users(team_member_users)
      assert_raise Ecto.NoResultsError, fn -> Teams.get_team_member_users!(team_member_users.id) end
    end

    test "change_team_member_users/1 returns a team_member_users changeset" do
      team_member_users = team_member_users_fixture()
      assert %Ecto.Changeset{} = Teams.change_team_member_users(team_member_users)
    end
  end
end
