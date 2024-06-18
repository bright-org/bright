defmodule Bright.TeamDefaultSkillPanelsTest do
  use Bright.DataCase
  import Bright.Factory

  alias Bright.TeamDefaultSkillPanels
  alias Bright.Teams.TeamDefaultSkillPanel

  describe "team_default_skill_panels" do
    @invalid_attrs %{team_id: nil, skill_panel_id: nil}

    test "list_team_default_skill_panels/0 returns all team_default_skill_panels" do
      team_default_skill_panel = insert(:team_default_skill_panel)
      assert TeamDefaultSkillPanels.list_team_default_skill_panels() == [team_default_skill_panel]
    end

    test "get_team_default_skill_panel!/1 returns the team_default_skill_panel with given id" do
      team_default_skill_panel = insert(:team_default_skill_panel)

      assert TeamDefaultSkillPanels.get_team_default_skill_panel!(team_default_skill_panel.id) ==
               team_default_skill_panel
    end

    test "create_team_default_skill_panel/1 with valid data creates a team_default_skill_panel" do
      team = insert(:team)
      skill_panel = insert(:skill_panel)

      valid_attrs = %{team_id: team.id, skill_panel_id: skill_panel.id}

      assert {:ok, %TeamDefaultSkillPanel{} = team_default_skill_panel} =
               TeamDefaultSkillPanels.create_team_default_skill_panel(valid_attrs)

      assert team_default_skill_panel.team_id == team.id
      assert team_default_skill_panel.skill_panel_id == skill_panel.id
    end

    test "create_team_default_skill_panel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               TeamDefaultSkillPanels.create_team_default_skill_panel(@invalid_attrs)
    end

    test "update_team_default_skill_panel/2 with valid data updates the team_default_skill_panel" do
      team_default_skill_panel = insert(:team_default_skill_panel)
      team = insert(:team)
      skill_panel = insert(:skill_panel)

      update_attrs = %{team_id: team.id, skill_panel_id: skill_panel.id}

      assert {:ok, %TeamDefaultSkillPanel{} = team_default_skill_panel} =
               TeamDefaultSkillPanels.update_team_default_skill_panel(
                 team_default_skill_panel,
                 update_attrs
               )

      assert team_default_skill_panel.team_id == team.id
      assert team_default_skill_panel.skill_panel_id == skill_panel.id
    end

    test "update_team_default_skill_panel/2 with invalid data returns error changeset" do
      team_default_skill_panel = insert(:team_default_skill_panel)

      assert {:error, %Ecto.Changeset{}} =
               TeamDefaultSkillPanels.update_team_default_skill_panel(
                 team_default_skill_panel,
                 @invalid_attrs
               )

      assert team_default_skill_panel ==
               TeamDefaultSkillPanels.get_team_default_skill_panel!(team_default_skill_panel.id)
    end

    test "delete_team_default_skill_panel/1 deletes the team_default_skill_panel" do
      team_default_skill_panel = insert(:team_default_skill_panel)

      assert {:ok, %TeamDefaultSkillPanel{}} =
               TeamDefaultSkillPanels.delete_team_default_skill_panel(team_default_skill_panel)

      assert_raise Ecto.NoResultsError, fn ->
        TeamDefaultSkillPanels.get_team_default_skill_panel!(team_default_skill_panel.id)
      end
    end

    test "get_team_default_skill_panel_from_team_id/1 returns the skill_panel with given team_id" do
      team_default_skill_panel =
        insert(:team_default_skill_panel) |> Repo.preload([:team, :skill_panel])

      assert TeamDefaultSkillPanels.get_team_default_skill_panel_from_team_id(
               team_default_skill_panel.team_id
             ) ==
               team_default_skill_panel.team
    end

    test "get_team_default_skill_panel_from_team_id/1 returns the skill_panel with given team_id (Multiple items)" do
      insert(:team_default_skill_panel)

      team_default_skill_panel =
        insert(:team_default_skill_panel) |> Repo.preload([:team, :skill_panel])

      assert TeamDefaultSkillPanels.get_team_default_skill_panel_from_team_id(
               team_default_skill_panel.team_id
             ) ==
               team_default_skill_panel.team
    end

    test "get_team_default_skill_panel_from_team_id/1 returns the nil with given team_id" do
      team = insert(:team)
      assert TeamDefaultSkillPanels.get_team_default_skill_panel_from_team_id(team.id) == nil
    end

    test "change_team_default_skill_panel/1 returns a team_default_skill_panel changeset" do
      team_default_skill_panel = insert(:team_default_skill_panel)

      assert %Ecto.Changeset{} =
               TeamDefaultSkillPanels.change_team_default_skill_panel(team_default_skill_panel)
    end
  end
end
