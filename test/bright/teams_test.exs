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
end
