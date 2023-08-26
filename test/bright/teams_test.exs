defmodule Bright.TeamsTest do
  use Bright.DataCase

  alias Bright.Teams
  alias Bright.Teams.TeamMemberUsers

  import Bright.Factory

  describe "create_team_multi/3" do
    test "create team and member users." do
      name = Faker.Lorem.word()
      admin_user = insert(:user)
      member1 = insert(:user)
      member2 = insert(:user)
      member_users = [member1, member2]

      assert {:ok, team, team_member_attrs} =
               Teams.create_team_multi(name, admin_user, member_users)

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
      assert admin_result.is_star == true
      # 管理者には招待メールは送信しない
      assert admin_result.invitation_sent_to == nil
      # 管理者本人は即時承認状態
      assert admin_result.invitation_confirmed_at != nil
      assert admin_result.invitation_confirmed_at <= TeamMemberUsers.now_for_confirmed_at()

      # チームメンバー(非作成者)の属性確認
      member_result = Enum.find(team.member_users, fn x -> x.user_id == member2.id end)
      # 非管理者
      assert member_result.is_admin == false
      # ジョイン承認するまではかならず非プライマリチーム
      assert member_result.is_star == false

      # 招待メールの送信先は対象ユーザーのプライマリメールアドレス
      assert member_result.invitation_sent_to == member2.email
      # 招待メール送信直後は承認日時はnil
      assert member_result.invitation_confirmed_at == nil

      # team_member_attrs内のbase64_encoded_tokenを認証にかけることで、invitation_confirmed_atが更新され承認状態となる
      team_member_attr =
        team_member_attrs
        |> Enum.find(fn team_member_attr ->
          team_member_attr.user_id == member_result.user_id
        end)

      # 間違った認証コードでは認証エラーとなる
      assert :error = Teams.get_invitation_token(team_member_attr.base64_encoded_token <> "1")

      # 正しい認証コードではtokenが取得できる
      assert {:ok, team_member_user} =
               Teams.get_invitation_token(team_member_attr.base64_encoded_token)

      # 認証することでinvitation_confirmed_atが更新される
      assert {:ok, confirmed_team_member_user} = Teams.confirm_invitation(team_member_user)

      assert confirmed_team_member_user.invitation_confirmed_at != nil

      assert confirmed_team_member_user.invitation_confirmed_at <=
               TeamMemberUsers.now_for_confirmed_at()

      # ２度目認証にかけても無視して正常終了扱いとなる
      assert {:ok, re_confirmed_team_member_user} = Teams.confirm_invitation(team_member_user)

      assert re_confirmed_team_member_user.invitation_confirmed_at ==
               confirmed_team_member_user.invitation_confirmed_at

      name2 = Faker.Lorem.word()
      # メンバーを追加しなくてもチーム作成は可能
      assert {:ok, team2, _team2_member_attrs} = Teams.create_team_multi(name2, admin_user, [])
      # メンバーは1名
      assert Enum.count(team2.member_users) == 1
      # チームメンバー(作成者)の属性確認
      admin_result2 = Enum.find(team2.member_users, fn x -> x.user_id == admin_user.id end)
      # 管理者
      assert admin_result2.is_admin == true
      # ２つ目以降のチームは非プライマリチーム
      assert admin_result2.is_star == false
    end
  end

  describe "list_joined_teams_by_user_id/1" do
    test "create team and member users. with no page params" do
      admin_team_name = Faker.Lorem.word()
      admin2_team_name = Faker.Lorem.word()
      user = insert(:user)
      other_user = insert(:user)

      assert {:ok, admin_team, _admin_team_member_user_attrs} =
               Teams.create_team_multi(admin_team_name, user, [other_user])

      assert {:ok, _admin_team2, _admin_team2_member_user_attrs} =
               Teams.create_team_multi(admin2_team_name, user, [other_user])

      page = Teams.list_joined_teams_by_user_id(user.id)
      related_teams = page.entries

      # ページ情報の確認
      assert page.page_number == 1
      assert page.total_entries == 2
      assert page.total_pages == 2

      # ページ条件を指定しない１件しか取得しない
      assert Enum.count(page.entries) == 1
      # 作成したチームの属性チェック
      admin_team_result = Enum.find(related_teams, fn x -> x.is_admin == true end)
      assert admin_team_result.team.name == admin_team.name
    end

    test "create team and member users. with page params" do
      admin_team_name = Faker.Lorem.word()
      joined_team_name = Faker.Lorem.word()
      joined_team2_name = Faker.Lorem.word()
      user = insert(:user)
      other_user = insert(:user)

      assert {:ok, admin_team, _admin_team_member_user_attrs} =
               Teams.create_team_multi(admin_team_name, user, [other_user])

      assert {:ok, joined_team, joined_team_member_user_attrs} =
               Teams.create_team_multi(joined_team_name, other_user, [user])

      assert {:ok, joined_team2, joined_team2_member_user_attrs} =
               Teams.create_team_multi(joined_team2_name, other_user, [user])

      page = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})

      # ページ情報の確認(未承認のユーザーは表示されないので自分が管理者のチームしか表示対象にならない)
      assert page.page_number == 1
      assert page.total_entries == 1
      assert page.total_pages == 1

      # チームへの招待を承認するととメンバーとして表示されるようになる
      joined_team_member_user_attr =
        joined_team_member_user_attrs
        |> Enum.find(fn attr ->
          attr.user_id == user.id
        end)

      assert {:ok, joined_team_member_user} =
               Teams.get_invitation_token(joined_team_member_user_attr.base64_encoded_token)

      assert {:ok, _joined_confirmed_team_member_user} =
               Teams.confirm_invitation(joined_team_member_user)

      page1_2 = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})

      # ページ情報の確認(表示されるチームがひとつ増える)
      assert page1_2.page_number == 1
      assert page1_2.total_entries == 2
      assert page1_2.total_pages == 1

      # ２つ目の参加チームも承認
      joined_team2_member_user_attr =
        joined_team2_member_user_attrs
        |> Enum.find(fn attr ->
          attr.user_id == user.id
        end)

      assert {:ok, joined_team_member_user} =
               Teams.get_invitation_token(joined_team2_member_user_attr.base64_encoded_token)

      assert {:ok, _joined_confirmed_team_member_user} =
               Teams.confirm_invitation(joined_team_member_user)

      page1_3 = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})

      # ページ情報の確認(表示されるチームがもうひとつ増える。最後は改ページ)
      assert page1_3.page_number == 1
      assert page1_3.total_entries == 3
      assert page1_3.total_pages == 2

      # ページパラメータで指定した数だけ結果が取得できる
      assert Enum.count(page1_3.entries) == 2

      related_teams = page1_3.entries

      # 作成したチームの属性チェック
      admin_team_result = Enum.find(related_teams, fn x -> x.is_admin == true end)
      assert admin_team_result.team.name == admin_team.name
      # ジョインしたチームの属性チェック
      joined_team_result = Enum.find(related_teams, fn x -> x.is_admin == false end)
      assert joined_team_result.team.name == joined_team.name

      page2 = Teams.list_joined_teams_by_user_id(user.id, %{page: 2, page_size: 2})
      related_teams2 = page2.entries

      # ページ情報の確認
      assert page2.page_number == 2
      assert page2.total_entries == 3
      assert page2.total_pages == 2

      # ２ページ目の残りは１件
      assert Enum.count(page2.entries) == 1

      # 2ページ目の属性チェック
      joined_team_result2 = Enum.find(related_teams2, fn x -> x.is_admin == false end)
      assert joined_team_result2.team.name == joined_team2.name
    end

    test "nothing joined team" do
      user = insert(:user)

      # チームを作成しないで検索
      page = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})

      # ページ情報の確認(結果は0件/１ページ)
      assert page.page_number == 1
      assert page.total_entries == 0
      assert page.total_pages == 1
    end
  end
end
