defmodule Bright.TeamsTest do
  use Bright.DataCase

  alias Bright.Teams
  alias Bright.Teams.TeamMemberUsers
  alias Bright.Teams.TeamSupporterTeam
  alias Bright.TeamTestHelper

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
      # 初期状態ではスターは指定しない
      assert admin_result.is_star == false
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

  describe "update_team_multi/3" do
    test "update team and member users." do
      create_name = Faker.Lorem.word()
      update_name = Faker.Lorem.word()
      admin_user = insert(:user)
      member1 = insert(:user)
      member2 = insert(:user)
      member3 = insert(:user)
      create_member_users = [member1, member2]
      update_member_users = [member1, member3]

      assert {:ok, team, _team_member_attrs} =
               Teams.create_team_multi(create_name, admin_user, create_member_users)

      assert {:ok, team, team_member_attrs} =
               Teams.update_team_multi(
                 team,
                 %{name: update_name},
                 admin_user,
                 [member3],
                 update_member_users
               )

      # チームの属性確認
      assert team.name == update_name
      # 更新に含まれていないメンバーは削除される
      assert Enum.count(team.member_users) == 3

      # チームメンバー(非作成者)の属性確認
      member_result = Enum.find(team.member_users, fn x -> x.user_id == member3.id end)
      # 非管理者
      assert member_result.is_admin == false
      # ジョイン承認するまではかならず非プライマリチーム
      assert member_result.is_star == false

      # 招待メールの送信先は対象ユーザーのプライマリメールアドレス
      assert member_result.invitation_sent_to == member3.email
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
    end
  end

  describe "list_joined_teams_by_user_id/3" do
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

      assert {:ok, _admin_team, _admin_team_member_user_attrs} =
               Teams.create_team_multi(admin_team_name, user, [other_user])

      assert {:ok, _joined_team, joined_team_member_user_attrs} =
               Teams.create_team_multi(joined_team_name, other_user, [user])

      assert {:ok, _joined_team2, joined_team2_member_user_attrs} =
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

      page2 = Teams.list_joined_teams_by_user_id(user.id, %{page: 2, page_size: 2})

      # ページ情報の確認
      assert page2.page_number == 2
      assert page2.total_entries == 3
      assert page2.total_pages == 2

      # ２ページ目の残りは１件
      assert Enum.count(page2.entries) == 1
    end

    test "change order of list_joined_teams_by_user_id" do
      team_name = Faker.Lorem.word()
      team_name2 = Faker.Lorem.word()
      user = insert(:user)

      assert {:ok, _team, _team_member_user_attrs} = Teams.create_team_multi(team_name, user, [])

      assert {:ok, _team2, _team2_member_user_attrs} =
               Teams.create_team_multi(team_name2, user, [])

      page = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})
      last_team = List.last(page.entries)

      # スター指定すると先頭にくる
      assert {:ok, _toggled_team_member_user} = Teams.toggle_is_star(last_team)

      page2 = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})
      first_team = List.first(page2.entries)
      assert first_team.id == last_team.id

      # スターを入れ替えると順序が入れ替わる
      last_team2 = List.last(page2.entries)
      assert {:ok, _toggled_team_member_user2} = Teams.toggle_is_star(last_team2)

      assert {:ok, _toggled_team_member_user3} = Teams.toggle_is_star(first_team)

      page2 = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})
      first_team2 = List.first(page2.entries)
      assert first_team2.id == last_team2.id
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

    test "exclude deleted_team" do
      user = insert(:user)
      team_name1 = Faker.Lorem.word()
      team_name2 = Faker.Lorem.word()

      {:ok, _team, _team_member_user_attrs} = Teams.create_team_multi(team_name1, user, [])

      {:ok, team2, _team2_member_user_attrs} = Teams.create_team_multi(team_name2, user, [])

      Teams.update_team(team2, %{disabled_at: NaiveDateTime.utc_now()})

      assert %Scrivener.Page{total_entries: 1} = Teams.list_joined_teams_by_user_id(user.id)
    end
  end

  describe "get_invitation_token/1" do
    setup do
      {base64_encoded_token, hashed_token} = Teams.build_invitation_token()

      %{
        base64_encoded_token: base64_encoded_token,
        team_member_user: insert(:team_member_users, invitation_token: hashed_token)
      }
    end

    test "returns team_member_user by invitation_token", %{
      base64_encoded_token: base64_encoded_token,
      team_member_user: team_member_user
    } do
      assert {:ok, team_member_user_by_token} = Teams.get_invitation_token(base64_encoded_token)
      assert team_member_user_by_token.id == team_member_user.id
    end

    test "returns :error with invalid token", %{base64_encoded_token: base64_encoded_token} do
      assert :error = Teams.get_invitation_token(base64_encoded_token <> "1")
    end

    test "returns team_member_user with not expired token", %{
      base64_encoded_token: base64_encoded_token,
      team_member_user: team_member_user
    } do
      {1, nil} =
        Repo.update_all(TeamMemberUsers,
          set: [
            inserted_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(-4 * 60 * 60 * 24)
              |> NaiveDateTime.add(1 * 60)
          ]
        )

      assert {:ok, team_member_user_by_token} = Teams.get_invitation_token(base64_encoded_token)
      assert team_member_user_by_token.id == team_member_user.id
    end

    test "returns team_member_user with expired token", %{
      base64_encoded_token: base64_encoded_token
    } do
      {1, nil} =
        Repo.update_all(TeamMemberUsers,
          set: [
            inserted_at:
              NaiveDateTime.utc_now()
              |> NaiveDateTime.add(-4 * 60 * 60 * 24)
          ]
        )

      assert :error = Teams.get_invitation_token(base64_encoded_token)
    end
  end

  describe "toggle_is_star/1" do
    test "toggle_star" do
      team_name = Faker.Lorem.word()
      user = insert(:user)

      assert {:ok, team, _team_member_user_attrs} = Teams.create_team_multi(team_name, user, [])

      page = Teams.list_joined_teams_by_user_id(user.id, %{page: 1, page_size: 2})

      team_member_user =
        page.entries
        |> Enum.find(fn team_member_user ->
          team_member_user.team_id == team.id
        end)

      # 初期状態ではスターは指定しない
      assert team_member_user.is_star == false

      # toggleすると逆転する
      assert {:ok, toggled_team_member_user} = Teams.toggle_is_star(team_member_user)
      assert toggled_team_member_user.is_star == true

      # 再度toggleすると再度逆転する
      assert {:ok, toggled_team_member_user_2} = Teams.toggle_is_star(toggled_team_member_user)
      assert toggled_team_member_user_2.is_star == false
    end
  end

  describe "list_joined_users_and_profiles_by_team_id/2" do
    test "list success" do
      team_name = Faker.Lorem.word()
      user = insert(:user)
      other_user = insert(:user)

      assert {:ok, team, team_member_user_attrs} =
               Teams.create_team_multi(team_name, user, [other_user])

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(team_member_user_attrs)

      # 作成者とメンバーで２件取得
      page = Teams.list_joined_users_and_profiles_by_team_id(team.id, %{page: 1, page_size: 99})
      assert page.total_entries == 2

      # 必ず最初に管理者がくる
      [admin_user | rest] = page.entries
      [normal_user] = rest
      assert admin_user.user_id == user.id
      assert admin_user.is_admin == true
      assert normal_user.user_id == other_user.id
      assert normal_user.is_admin == false
    end
  end

  describe "list_joined_users_and_profiles_by_team_id_without_myself/3" do
    test "list success" do
      team_name = Faker.Lorem.word()
      user = insert(:user)
      other_user1 = insert(:user)
      other_user2 = insert(:user)

      assert {:ok, team, team_member_user_attrs} =
               Teams.create_team_multi(team_name, user, [other_user1, other_user2])

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(team_member_user_attrs)

      # 指定された自分自身は対象外なので2件しか取得されない
      page =
        Teams.list_joined_users_and_profiles_by_team_id_without_myself(other_user1.id, team.id, %{
          page: 1,
          page_size: 99
        })

      assert page.total_entries == 2

      # 必ず最初に管理者がくる
      [admin_user | rest] = page.entries
      [normal_user] = rest
      assert admin_user.user_id == user.id
      assert admin_user.is_admin == true
      assert normal_user.user_id == other_user2.id
      assert normal_user.is_admin == false
    end
  end

  describe "joined_teams_by_user_id!/2" do
    test "success" do
      team_name = Faker.Lorem.word()
      current_user = insert(:user)
      other_user1 = insert(:user)

      assert {:ok, _team, team_member_user_attrs} =
               Teams.create_team_multi(team_name, current_user, [other_user1])

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(team_member_user_attrs)

      assert Teams.joined_teams_by_user_id!(current_user.id, other_user1.id)
    end

    test "failure" do
      team_name = Faker.Lorem.word()
      current_user = insert(:user)
      other_user1 = insert(:user)
      other_user2 = insert(:user)

      assert {:ok, _team, team_member_user_attrs} =
               Teams.create_team_multi(team_name, current_user, [other_user1])

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(team_member_user_attrs)

      assert_raise Ecto.NoResultsError, fn ->
        Teams.joined_teams_by_user_id!(current_user.id, other_user2.id)
      end
    end
  end

  describe "get_enable_functions_by_joined_teams!/1" do
    test "disable all functions" do
      team_name = Faker.Lorem.word()
      admin_user = insert(:user)

      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [])

      enable_functions = Teams.get_enable_functions_by_joined_teams!(admin_user.id)

      assert enable_functions.enable_team_up_functions == false
      assert enable_functions.enable_hr_functions == false
    end

    test "enable team_up_factions" do
      team_name = Faker.Lorem.word()
      admin_user = insert(:user)

      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [], %{
                 enable_team_up_functions: true,
                 enable_hr_functions: false
               })

      enable_functions = Teams.get_enable_functions_by_joined_teams!(admin_user.id)

      assert enable_functions.enable_team_up_functions == true
      assert enable_functions.enable_hr_functions == false
    end

    test "enable hr_factions" do
      team_name = Faker.Lorem.word()
      admin_user = insert(:user)

      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [], %{
                 enable_team_up_functions: false,
                 enable_hr_functions: true
               })

      enable_functions = Teams.get_enable_functions_by_joined_teams!(admin_user.id)

      assert enable_functions.enable_team_up_functions == false
      assert enable_functions.enable_hr_functions == true
    end

    test "enable all factions and multi teams records" do
      team_name = Faker.Lorem.word()
      admin_user = insert(:user)

      # １件以上enabled trueのチームがあれば複数件あってもtrueになる
      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [], %{
                 enable_team_up_functions: true,
                 enable_hr_functions: true
               })

      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [], %{
                 enable_team_up_functions: true,
                 enable_hr_functions: true
               })

      enable_functions = Teams.get_enable_functions_by_joined_teams!(admin_user.id)

      assert enable_functions.enable_team_up_functions == true
      assert enable_functions.enable_hr_functions == true
    end

    test "no joined team" do
      team_name = Faker.Lorem.word()
      admin_user = insert(:user)
      member_user = insert(:user)

      # チームに招待されていても承認していなければカウントされない
      assert {:ok, _team, _team_member_user_attrs} =
               Teams.create_team_multi(team_name, admin_user, [member_user], %{
                 enable_team_up_functions: true,
                 enable_hr_functions: true
               })

      assert {:ok, _team2, _team_member_user_attrs2} =
               Teams.create_team_multi(team_name, admin_user, [member_user], %{
                 enable_team_up_functions: true,
                 enable_hr_functions: true
               })

      enable_functions = Teams.get_enable_functions_by_joined_teams!(member_user.id)

      assert enable_functions.enable_team_up_functions == false
      assert enable_functions.enable_hr_functions == false
    end

    test "no count not confirmed team" do
      admin_user = insert(:user)

      # チームに所属していない場合は全機能false
      enable_functions = Teams.get_enable_functions_by_joined_teams!(admin_user.id)

      assert enable_functions.enable_team_up_functions == false
      assert enable_functions.enable_hr_functions == false
    end
  end

  describe "sort_team_member_users/1" do
    test "sorts list" do
      admin = insert(:user)
      member1 = insert(:user)
      member2 = insert(:user)
      member_users = [member1, member2]
      {:ok, team, _} = Teams.create_team_multi("test", admin, member_users)

      [admin_member_user, team_member_user_1, team_member_user_2] = team.member_users
      {:ok, admin_member_user} = Teams.toggle_is_star(admin_member_user)

      {:ok, team_member_user_2} =
        Teams.update_team_member_users_invitation_confirmed_at(team_member_user_2, %{
          invitation_confirmed_at: NaiveDateTime.utc_now()
        })

      {:ok, team_member_user_1} =
        Teams.update_team_member_users_invitation_confirmed_at(team_member_user_1, %{
          invitation_confirmed_at: NaiveDateTime.utc_now() |> NaiveDateTime.add(1)
        })

      args = [team_member_user_1, team_member_user_2, admin_member_user]
      actual_ids = Enum.map(Teams.sort_team_member_users(args), & &1.id)

      expected_ids =
        Enum.map([admin_member_user, team_member_user_2, team_member_user_1], & &1.id)

      assert expected_ids == actual_ids
    end
  end

  describe "list_confirmed_team_member_users_by_team" do
    test "returns list" do
      team = insert(:team)
      user_1 = insert(:user)
      user_2 = insert(:user)
      user_3 = insert(:user)

      # user_1/2 は招待確認済み, user_3は未確認
      Enum.each([user_1, user_2], &insert(:team_member_users, team: team, user: &1))
      insert(:team_member_users_unconfirmed, team: team, user: user_3)

      member_users = Teams.list_confirmed_team_member_users_by_team(team)
      user_ids = Enum.map([user_1, user_2], & &1.id) |> Enum.sort()
      ret_user_ids = Enum.map(member_users, & &1.user_id) |> Enum.sort()

      assert user_ids == ret_user_ids
    end
  end

  describe "team_supporter_teams life cycle" do
    test "normal life cycle" do
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)

      {:ok, supporter_team, supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(supporter_team_member_attrs)

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)

      {:ok, supportee_team, _supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(supporter_team_member_attrs)

      # 支援されるチームの管理者から支援するチームのメンバーへ支援依頼
      {:ok, %TeamSupporterTeam{} = request_team_supporter_team} =
        Teams.request_support_from_suportee_team(
          supportee_team.id,
          supportee_team_admin_user.id,
          supporter_team_member_user.id
        )

      assert request_team_supporter_team.supportee_team_id == supportee_team.id
      assert request_team_supporter_team.supporter_team_id == nil
      assert request_team_supporter_team.request_from_user_id == supportee_team_admin_user.id
      assert request_team_supporter_team.request_to_user_id == supporter_team_member_user.id
      assert request_team_supporter_team.status == :requesting
      assert request_team_supporter_team.request_datetime <= NaiveDateTime.utc_now()
      assert request_team_supporter_team.start_datetime == nil
      assert request_team_supporter_team.end_datetime == nil

      # 支援依頼はユーザー個人に対してなので管理者でも参照できない
      assert %{total_entries: 0} =
               Teams.list_support_request_by_supporter_user_id(supporter_team_admin_user.id)

      # 支援チームのメンバー向けなので支援依頼をした本人も参照できない
      assert %{total_entries: 0} =
               Teams.list_support_request_by_supporter_user_id(supporter_team_admin_user.id)

      # リクエスト中の支援依頼一覧を取得
      page_list_support_request =
        Teams.list_support_request_by_supporter_user_id(supporter_team_member_user.id)

      assert page_list_support_request.total_entries == 1
      support_request = List.first(page_list_support_request.entries)
      assert support_request.status == :requesting
      assert support_request.request_datetime <= NaiveDateTime.utc_now()
      assert support_request.start_datetime == nil
      assert support_request.end_datetime == nil
      assert support_request.supportee_team.name == supportee_team.name
      assert support_request.request_from_user.name == supportee_team_admin_user.name
      assert support_request.request_to_user.name == supporter_team_member_user.name

      # 支援依頼を承諾する
      {:ok, %TeamSupporterTeam{} = accept_team_supporter_team} =
        Teams.accept_support_by_supporter_team(request_team_supporter_team, supporter_team.id)

      assert accept_team_supporter_team.supportee_team_id == supportee_team.id
      assert accept_team_supporter_team.supporter_team_id == supporter_team.id
      assert accept_team_supporter_team.request_from_user_id == supportee_team_admin_user.id
      assert accept_team_supporter_team.request_to_user_id == supporter_team_member_user.id
      assert accept_team_supporter_team.status == :supporting

      assert accept_team_supporter_team.request_datetime ==
               request_team_supporter_team.request_datetime

      assert accept_team_supporter_team.start_datetime <= NaiveDateTime.utc_now()
      assert accept_team_supporter_team.end_datetime == nil

      # 支援依頼の一覧に表示されなくなる
      assert %{total_entries: 0} =
               Teams.list_support_request_by_supporter_user_id(supporter_team_member_user.id)

      # 支援中の一覧のチーム一覧に表示される
      page_list_supporting_teams =
        Teams.list_supportee_teams_by_supporter_user_id(supporter_team_member_user.id)

      assert page_list_supporting_teams.total_entries == 1
      assert supporting_team = List.first(page_list_supporting_teams.entries)
      assert supporting_team.name == supportee_team.name

      # 支援を終了する
      {:ok, %TeamSupporterTeam{} = support_ended_team_supporter_team} =
        Teams.end_support_by_supporter_team(accept_team_supporter_team)

      assert support_ended_team_supporter_team.supportee_team_id == supportee_team.id
      assert support_ended_team_supporter_team.supporter_team_id == supporter_team.id

      assert support_ended_team_supporter_team.request_from_user_id ==
               supportee_team_admin_user.id

      assert support_ended_team_supporter_team.request_to_user_id == supporter_team_member_user.id
      assert support_ended_team_supporter_team.status == :support_ended

      assert support_ended_team_supporter_team.request_datetime ==
               request_team_supporter_team.request_datetime

      assert support_ended_team_supporter_team.start_datetime ==
               accept_team_supporter_team.start_datetime

      assert support_ended_team_supporter_team.end_datetime <= NaiveDateTime.utc_now()

      # 支援中の一覧に表示されなくなる
      assert %{total_entries: 0} =
               Teams.list_supportee_teams_by_supporter_user_id(supporter_team_member_user.id)
    end

    test "reject support request" do
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)

      {:ok, _supporter_team, supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(supporter_team_member_attrs)

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)

      {:ok, supportee_team, _supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(supporter_team_member_attrs)

      # 支援されるチームの管理者から支援するチームのメンバーへ支援依頼
      {:ok, %TeamSupporterTeam{} = request_team_supporter_team} =
        Teams.request_support_from_suportee_team(
          supportee_team.id,
          supportee_team_admin_user.id,
          supporter_team_member_user.id
        )

      # リクエスト中の支援依頼一覧を取得
      page_list_support_request =
        Teams.list_support_request_by_supporter_user_id(supporter_team_member_user.id)

      assert page_list_support_request.total_entries == 1
      support_request = List.first(page_list_support_request.entries)
      assert support_request.status == :requesting

      # 支援依頼を拒否する

      {:ok, %TeamSupporterTeam{} = regect_team_supporter_team} =
        Teams.reject_support_by_supporter_team(support_request)

      assert regect_team_supporter_team.supportee_team_id == supportee_team.id
      assert regect_team_supporter_team.supporter_team_id == nil
      assert regect_team_supporter_team.request_from_user_id == supportee_team_admin_user.id
      assert regect_team_supporter_team.request_to_user_id == supporter_team_member_user.id
      assert regect_team_supporter_team.status == :reject

      assert regect_team_supporter_team.request_datetime ==
               request_team_supporter_team.request_datetime

      assert regect_team_supporter_team.start_datetime == nil
      assert regect_team_supporter_team.end_datetime == nil

      # リクエスト中の支援依頼に表示されない
      assert %{total_entries: 0} =
               Teams.list_support_request_by_supporter_user_id(supporter_team_member_user.id)

      # 支援中のチーム一覧に表示されない
      assert %{total_entries: 0} =
               Teams.list_supportee_teams_by_supporter_user_id(supporter_team_member_user.id)
    end
  end

  describe "list_support_request_by_supporter_user_id/2" do
    test "result 0 entry" do
      user = insert(:user)
      assert %{total_entries: 0} = Teams.list_support_request_by_supporter_user_id(user.id)
    end

    test "result multi entries with sort order" do
      # 支援する側のチーム
      supporter_team_admin_user = insert(:user)

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)

      {:ok, supportee_team, _supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # 支援される側のチーム2
      supportee_team_name2 = Faker.Lorem.word()
      supportee_team_admin_user2 = insert(:user)
      supportee_team_member_user2 = insert(:user)

      {:ok, supportee_team2, _supportee_team_member_attrs2} =
        Teams.create_team_multi(
          supportee_team_name2,
          supportee_team_admin_user2,
          [supportee_team_member_user2],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      utc_now = NaiveDateTime.utc_now()
      # 支援依頼日時が古い方が下
      {:ok, %TeamSupporterTeam{} = _team_support_team1} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team.id,
          request_from_user_id: supportee_team_admin_user.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :requesting,
          request_datetime: NaiveDateTime.add(utc_now, -1, :second)
        })

      # ステータスがrequesting以外は表示対象外
      {:ok, %TeamSupporterTeam{} = _team_support_team1} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team.id,
          request_from_user_id: supportee_team_admin_user.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :supporting,
          request_datetime: utc_now,
          start_datetime: utc_now
        })

      # request_to_user_idが異なるレコードは表示対象外
      {:ok, %TeamSupporterTeam{} = _team_support_team1} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team.id,
          request_from_user_id: supporter_team_admin_user.id,
          request_to_user_id: supportee_team_admin_user.id,
          status: :supporting,
          request_datetime: utc_now,
          start_datetime: utc_now
        })

      # 支援依頼日時が新しい方が上
      {:ok, %TeamSupporterTeam{} = _team_support_team2} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team2.id,
          request_from_user_id: supportee_team_admin_user2.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :requesting,
          request_datetime: utc_now
        })

      page_list_support_request =
        Teams.list_support_request_by_supporter_user_id(supporter_team_admin_user.id, %{
          page: 1,
          page_size: 2
        })

      assert page_list_support_request.total_entries == 2
      support_request_1 = Enum.at(page_list_support_request.entries, 0)
      assert support_request_1.status == :requesting
      assert support_request_1.request_from_user_id == supportee_team_admin_user2.id
      assert support_request_1.supportee_team_id == supportee_team2.id
      support_request_2 = Enum.at(page_list_support_request.entries, 1)
      assert support_request_2.status == :requesting
      assert support_request_2.request_from_user_id == supportee_team_admin_user.id
      assert support_request_2.supportee_team_id == supportee_team.id
    end
  end

  describe "list_supportee_teams_by_supporter_user_id/2" do
    test "result 0 entry" do
      user = insert(:user)
      assert %{total_entries: 0} = Teams.list_supportee_teams_by_supporter_user_id(user.id)
    end

    test "result multi entries with sort order" do
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)

      {:ok, supporter_team, supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # 全員チーム招待に承認する
      TeamTestHelper.cofirm_invitation(supporter_team_member_attrs)

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)

      {:ok, supportee_team, _supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # 支援される側のチーム2
      supportee_team_name2 = Faker.Lorem.word()
      supportee_team_admin_user2 = insert(:user)
      supportee_team_member_user2 = insert(:user)

      {:ok, supportee_team2, _supportee_team_member_attrs2} =
        Teams.create_team_multi(
          supportee_team_name2,
          supportee_team_admin_user2,
          [supportee_team_member_user2],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      utc_now = NaiveDateTime.utc_now()
      # 支援開始日が新しい方が上
      {:ok, %TeamSupporterTeam{} = _team_support_team1} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team.id,
          supporter_team_id: supporter_team.id,
          request_from_user_id: supportee_team_admin_user.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :supporting,
          request_datetime: utc_now,
          start_datetime: utc_now
        })

      # ステータスが異なるレコードは対象外
      {:ok, %TeamSupporterTeam{} = _team_support_team3} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team2.id,
          request_from_user_id: supportee_team_admin_user2.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :requesting,
          request_datetime: utc_now
        })

      # 支援開始日が古い方が下
      {:ok, %TeamSupporterTeam{} = _team_support_team2} =
        Teams.create_team_supporter_team(%{
          supportee_team_id: supportee_team2.id,
          supporter_team_id: supporter_team.id,
          request_from_user_id: supportee_team_admin_user2.id,
          request_to_user_id: supporter_team_admin_user.id,
          status: :supporting,
          request_datetime: utc_now,
          start_datetime: NaiveDateTime.add(utc_now, -1, :second)
        })

      page_list_supportee_teams =
        Teams.list_supportee_teams_by_supporter_user_id(supporter_team_admin_user.id, %{
          page: 1,
          page_size: 2
        })

      assert page_list_supportee_teams.total_entries == 2
      supportee_team_1 = Enum.at(page_list_supportee_teams.entries, 0)
      assert supportee_team_1.name == supportee_team.name
      supportee_team_2 = Enum.at(page_list_supportee_teams.entries, 1)
      assert supportee_team_2.name == supportee_team2.name
    end

    test "not confirm invitation team" do
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)

      {:ok, supporter_team, _supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # チーム招待に承認しない

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)

      {:ok, supportee_team, _supportee_team_member_attrs} =
        Teams.create_team_multi(supportee_team_name, supportee_team_admin_user, [], %{
          enable_team_up_functions: true,
          enable_hr_functions: false
        })

      # 支援されるチームの管理者から支援するチームのメンバーへ支援依頼
      {:ok, %TeamSupporterTeam{} = request_team_supporter_team} =
        Teams.request_support_from_suportee_team(
          supportee_team.id,
          supportee_team_admin_user.id,
          supporter_team_admin_user.id
        )

      # 支援依頼を承諾する
      {:ok, %TeamSupporterTeam{} = _accept_team_supporter_team} =
        Teams.accept_support_by_supporter_team(request_team_supporter_team, supporter_team.id)

      # 人材チームに招待されていてもチームへの参加を承認していないメンバーは確認できない
      assert %{total_entries: 0} =
               Teams.list_support_request_by_supporter_user_id(supporter_team_member_user.id)
    end
  end

  describe "list_user_ids_related_team_by_user/1" do
    test "returns user_ids" do
      [user, user_2, user_3] = insert_list(3, :user)
      team = insert(:team)
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      assert [user_2.id] == Teams.list_user_ids_related_team_by_user(user)
      assert [user.id] == Teams.list_user_ids_related_team_by_user(user_2)
      assert [] == Teams.list_user_ids_related_team_by_user(user_3)
    end
  end

  describe "is_my_supportee_team_or_supporter_team?/2" do
    test "check supputer relation on support life cycle" do
      # 支援元先両方のチームに所属する特異な人
      both_team_member_user = insert(:user)
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)

      {:ok, supporter_team, supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user, both_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # 全体はチーム招待に承諾しない=管理者は自動承認済、メンバーは未承認のまま
      # 両方に所属する人のみ承認する
      supporter_team_member_attrs
      |> Enum.filter(fn supporter_team_member_attr ->
        supporter_team_member_attr.user_id == both_team_member_user.id
      end)
      |> TeamTestHelper.cofirm_invitation()

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)

      {:ok, supportee_team, supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user, both_team_member_user],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # チーム招待に承諾しない=管理者は自動承認済、メンバーは未承認のまま
      # 両方に所属する人のみ承認する
      supportee_team_member_attrs
      |> Enum.filter(fn supportee_team_member_attr ->
        supportee_team_member_attr.user_id == both_team_member_user.id
      end)
      |> TeamTestHelper.cofirm_invitation()

      # 支援依頼がない段階ではいずれも支援関係判定されない
      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_admin_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_admin_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_member_user.id,
                 supportee_team.id
               )

      # 支援されるチームの管理者から支援するチームのメンバーへ支援依頼
      {:ok, %TeamSupporterTeam{} = request_team_supporter_team} =
        Teams.request_support_from_suportee_team(
          supportee_team.id,
          supportee_team_admin_user.id,
          supporter_team_member_user.id
        )

      # 支援依頼の段階ではいずれも支援関係判定されない
      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_admin_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_admin_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_member_user.id,
                 supportee_team.id
               )

      # 支援依頼を承諾する
      {:ok, %TeamSupporterTeam{} = accept_team_supporter_team} =
        Teams.accept_support_by_supporter_team(request_team_supporter_team, supporter_team.id)

      # 支援依頼承認済の場合、
      # チーム招待承認済の場合は支援関係判定true
      assert true ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_admin_user.id,
                 supporter_team.id
               )

      assert true ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_admin_user.id,
                 supportee_team.id
               )

      assert true ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supportee_team.id
               )

      assert true ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supporter_team.id
               )

      # チーム招待未承認の場合は支援関係判定false
      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_member_user.id,
                 supportee_team.id
               )

      # 支援を終了する
      {:ok, %TeamSupporterTeam{} = _support_ended_team_supporter_team} =
        Teams.end_support_by_supporter_team(accept_team_supporter_team)

      # 支援終了の段階ではいずれも支援関係判定されない
      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_admin_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_admin_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supportee_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 both_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supportee_team_member_user.id,
                 supporter_team.id
               )

      assert false ==
               Teams.is_my_supportee_team_or_supporter_team?(
                 supporter_team_member_user.id,
                 supportee_team.id
               )
    end
  end

  describe "joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!/2" do
    # joined_supportee_teams_or_supporter_teams_by_user_id?の全バリエーションも含む
    test "check joine team and supputer relation on support life cycle" do
      # 支援する側のチーム
      supporter_team_name = Faker.Lorem.word()
      supporter_team_admin_user = insert(:user)
      supporter_team_member_user = insert(:user)
      supporter_team_member_user2 = insert(:user)

      {:ok, supporter_team, supporter_team_member_attrs} =
        Teams.create_team_multi(
          supporter_team_name,
          supporter_team_admin_user,
          [supporter_team_member_user, supporter_team_member_user2],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: true
          }
        )

      # 管理者は自動承認済、
      # メンバー1は承認する
      # メンバー2は未承認のまま
      supporter_team_member_attrs
      |> Enum.filter(fn supporter_team_member_attr ->
        supporter_team_member_attr.user_id == supporter_team_member_user.id
      end)
      |> TeamTestHelper.cofirm_invitation()

      # 支援される側のチーム
      supportee_team_name = Faker.Lorem.word()
      supportee_team_admin_user = insert(:user)
      supportee_team_member_user = insert(:user)
      supportee_team_member_user2 = insert(:user)

      {:ok, supportee_team, supportee_team_member_attrs} =
        Teams.create_team_multi(
          supportee_team_name,
          supportee_team_admin_user,
          [supportee_team_member_user, supportee_team_member_user2],
          %{
            enable_team_up_functions: true,
            enable_hr_functions: false
          }
        )

      # 管理者は自動承認済、
      # メンバー1は承認する
      # メンバー2は未承認のまま
      supportee_team_member_attrs
      |> Enum.filter(fn supportee_team_member_attr ->
        supportee_team_member_attr.user_id == supportee_team_member_user.id
      end)
      |> TeamTestHelper.cofirm_invitation()

      # 自分が所属するチームに所属していればtrueを返す
      assert Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
               supporter_team_admin_user.id,
               supporter_team_member_user.id
             )

      # 自分が所属するチームに招待されていても未承認であればForbiddenResourceErrorをraiseする
      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supporter_team_admin_user.id,
          supporter_team_member_user2.id
        )
      end

      # 支援関係にない他チームのメンバーであればForbiddenResourceErrorをraiseする
      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supporter_team_admin_user.id,
          supportee_team_member_user.id
        )
      end

      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supportee_team_admin_user.id,
          supporter_team_member_user.id
        )
      end

      # 支援されるチームの管理者から支援するチームのメンバーへ支援依頼
      {:ok, %TeamSupporterTeam{} = request_team_supporter_team} =
        Teams.request_support_from_suportee_team(
          supportee_team.id,
          supportee_team_admin_user.id,
          supporter_team_member_user.id
        )

      # 支援依頼の段階では支援関係を結んでいない場合と同様にForbiddenResourceErrorをraiseする
      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supporter_team_admin_user.id,
          supportee_team_member_user.id
        )
      end

      # 支援依頼を承諾する
      {:ok, %TeamSupporterTeam{} = _accept_team_supporter_team} =
        Teams.accept_support_by_supporter_team(request_team_supporter_team, supporter_team.id)

      # 支援依頼が承諾されたことで支援先のメンバーの一員として判定されtrueを返す
      assert Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
               supportee_team_admin_user.id,
               supporter_team_member_user.id
             )

      # 支援依頼が承諾されたチームに招待されていても未承認であればForbiddenResourceErrorをraiseする
      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supporter_team_admin_user.id,
          supportee_team_member_user2.id
        )
      end

      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        Teams.joined_teams_or_supportee_teams_or_supporter_teams_by_user_id!(
          supportee_team_admin_user.id,
          supporter_team_member_user2.id
        )
      end

      # 支援を終了、支援拒否のケースは!= :supporting のケースなので割愛
    end
  end

  describe "get_team_type_by_team/1" do
    test "hr_support_team case" do
      team = insert(:hr_support_team)
      assert :hr_support_team == Teams.get_team_type_by_team(team)
    end

    test "teamup_team case" do
      team = insert(:teamup_team)
      assert :teamup_team == Teams.get_team_type_by_team(team)
    end

    test "gerenal_team case" do
      team = insert(:team)
      assert :general_team == Teams.get_team_type_by_team(team)
    end

    test "undefined_team case" do
      # 現プランでは存在しないが、HR機能だけ使える場合も人材支援チーム扱いとする
      team = insert(:undefined_team)
      assert :hr_support_team == Teams.get_team_type_by_team(team)
    end

    test "custom_group case" do
      user = insert(:user)
      custom_group = insert(:custom_group, user_id: user.id)
      assert :custom_group == Teams.get_team_type_by_team(custom_group)
    end
  end
end
