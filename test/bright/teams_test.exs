defmodule Bright.TeamsTest do
  use Bright.DataCase

  alias Bright.Teams

  import Bright.Factory

  describe "create_team_multi/3" do
    test "create team and member users." do
      name = Faker.Lorem.word()
      admin_user = insert(:user)
      member1 = insert(:user)
      member2 = insert(:user)
      member_users = [member1, member2]

      assert {:ok, team} = Teams.create_team_multi(name, admin_user, member_users)

      # チームの属性確認
      assert team.name == name
      # 現サイクル実装では人材チーム機能は常にfalse
      assert team.enable_hr_functions == false
      # 作成者も含めメンバーは3名
      assert Enum.count(team.member_users) == 3

      # チームメンバー(作成者)の属性確認
      admin_result = Enum.find(team.member_users, fn x -> x.user_id == admin_user.id end)
      # 管理者
      assert admin_result.is_admin == true
      # 管理者の最初のチームは即時プライマリチーム
      assert admin_result.is_primary == true

      # チームメンバー(非作成者)の属性確認
      member_result = Enum.find(team.member_users, fn x -> x.user_id == member2.id end)
      # 非管理者
      assert member_result.is_admin == false
      # ジョイン承認するまではかならず非プライマリチーム
      assert member_result.is_primary == false

      name2 = Faker.Lorem.word()
      # メンバーを追加しなくてもチーム作成は可能
      assert {:ok, team2} = Teams.create_team_multi(name2, admin_user, [])
      # メンバーは1名
      assert Enum.count(team2.member_users) == 1
      # チームメンバー(作成者)の属性確認
      admin_result2 = Enum.find(team2.member_users, fn x -> x.user_id == admin_user.id end)
      # 管理者
      assert admin_result2.is_admin == true
      # ２つ目以降のチームは非プライマリチーム
      assert admin_result2.is_primary == false
    end
  end

  describe "list_joined_teams_by_user_id/1" do
    test "create team and member users." do
      admin_team_name = Faker.Lorem.word()
      joined_team_name = Faker.Lorem.word()
      user = insert(:user)
      other_user = insert(:user)

      assert {:ok, admin_team} = Teams.create_team_multi(admin_team_name, user, [other_user])
      assert {:ok, joined_team} = Teams.create_team_multi(joined_team_name, other_user, [user])

      related_teams = Teams.list_joined_teams_by_user_id(user.id)

      # 作成したチームも含めジョインしたすべてのチームが取得できる
      assert Enum.count(related_teams) == 2
      # 作成したチームの属性チェック
      admin_team_result = Enum.find(related_teams, fn x -> x.is_admin == true end)
      assert admin_team_result.team.name == admin_team.name
      # ジョインしたチームの属性チェック
      joined_team_result = Enum.find(related_teams, fn x -> x.is_admin == false end)
      assert joined_team_result.team.name == joined_team.name
    end
  end
end
