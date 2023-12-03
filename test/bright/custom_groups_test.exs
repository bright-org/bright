defmodule Bright.CustomGroupsTest do
  use Bright.DataCase

  alias Bright.CustomGroups
  alias Bright.CustomGroups.CustomGroupMemberUser

  import Bright.Factory

  setup do
    user = insert(:user)
    %{user: user}
  end

  describe "custom_groups" do
    alias Bright.CustomGroups.CustomGroup

    @invalid_attrs %{name: nil}

    test "list_custom_groups/0 returns all custom_groups", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert CustomGroups.list_custom_groups() == [custom_group]
    end

    test "list_user_custom_groups/1 returns user's custom_groups", %{user: user} do
      user_2 = insert(:user)
      custom_group_1 = insert(:custom_group, user_id: user.id)
      custom_group_2 = insert(:custom_group, user_id: user_2.id)

      assert CustomGroups.list_user_custom_groups(user.id) == [custom_group_1]
      assert CustomGroups.list_user_custom_groups(user_2.id) == [custom_group_2]
    end

    test "list_and_filter_valid_users/2", %{user: user} do
      user_2 = insert(:user)
      user_3 = insert(:user)

      custom_group =
        insert(:custom_group,
          user_id: user.id,
          member_users: [
            build(:custom_group_member_user, user_id: user_2.id),
            build(:custom_group_member_user, user_id: user_3.id)
          ]
        )

      # user_2 チームメンバー
      # user_3 チームメンバー外
      insert(:team,
        member_users: [
          build(:team_member_users, user: user),
          build(:team_member_users, user: user_2)
        ]
      )

      assert [user_2] == CustomGroups.list_and_filter_valid_users(custom_group, user)

      refute Repo.get_by(CustomGroupMemberUser,
               custom_group_id: custom_group.id,
               user_id: user_3.id
             )
    end

    test "filter_valid_users", %{user: user} do
      user_2 = insert(:user)
      user_3 = insert(:user)

      custom_group =
        insert(:custom_group,
          user: user,
          user_id: user.id,
          member_users: [
            build(:custom_group_member_user, user_id: user_2.id, user: user_2),
            build(:custom_group_member_user, user_id: user_3.id, user: user_3)
          ]
        )

      # user_2 チームメンバー
      # user_3 チームメンバー外
      insert(:team,
        member_users: [
          build(:team_member_users, user: user),
          build(:team_member_users, user: user_2)
        ]
      )

      assert {[user_2], [user_3]} == CustomGroups.filter_valid_users(custom_group)

      refute Repo.get_by(CustomGroupMemberUser,
               custom_group_id: custom_group.id,
               user_id: user_3.id
             )
    end

    test "get_custom_group!/1 returns the custom_group with given id", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert CustomGroups.get_custom_group!(custom_group.id) == custom_group
    end

    test "get_custom_group_by!/1 returns the custom_group with given condition", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)

      assert CustomGroups.get_custom_group_by!(id: custom_group.id, user_id: user.id) ==
               custom_group
    end

    test "create_custom_group/1 with valid data creates a custom_group", %{user: user} do
      [user_1, user_2] = insert_pair(:user)

      valid_attrs = %{
        name: "some name",
        user_id: user.id,
        member_users: [
          %{user_id: user_1.id, position: 2},
          %{user_id: user_2.id, position: 1}
        ]
      }

      assert {:ok, %CustomGroup{} = custom_group} = CustomGroups.create_custom_group(valid_attrs)
      assert custom_group.name == "some name"

      %{member_users: [member_user_1, member_user_2]} =
        Repo.preload(custom_group, [:member_users], force: true)

      assert %{position: 1, user_id: user_2.id} == Map.take(member_user_1, ~w(position user_id)a)
      assert %{position: 2, user_id: user_1.id} == Map.take(member_user_2, ~w(position user_id)a)
    end

    test "create_custom_group/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CustomGroups.create_custom_group(@invalid_attrs)
    end

    test "update_custom_group/2 with valid data updates the custom_group", %{user: user} do
      [user_1, user_2, user_3] = insert_list(3, :user)

      custom_group =
        insert(
          :custom_group,
          user_id: user.id,
          member_users: [
            build(:custom_group_member_user, user_id: user_1.id, position: 1),
            build(:custom_group_member_user, user_id: user_2.id, position: 2)
          ]
        )

      update_attrs = %{
        name: "some updated name",
        member_users: [
          %{user_id: user_3.id, position: 1},
          %{user_id: user_1.id, position: 2}
        ]
      }

      assert {:ok, %CustomGroup{} = custom_group} =
               CustomGroups.update_custom_group(custom_group, update_attrs)

      assert custom_group.name == "some updated name"

      %{member_users: [member_user_1, member_user_2]} =
        Repo.preload(custom_group, [:member_users], force: true)

      assert %{position: 1, user_id: user_3.id} == Map.take(member_user_1, ~w(position user_id)a)
      assert %{position: 2, user_id: user_1.id} == Map.take(member_user_2, ~w(position user_id)a)

      assert 2 == Repo.aggregate(CustomGroupMemberUser, :count)
    end

    test "update_custom_group/2 with invalid data returns error changeset", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)

      assert {:error, %Ecto.Changeset{}} =
               CustomGroups.update_custom_group(custom_group, @invalid_attrs)

      assert custom_group == CustomGroups.get_custom_group!(custom_group.id)
    end

    test "delete_custom_group/1 deletes the custom_group", %{user: user} do
      custom_group =
        insert(
          :custom_group,
          user_id: user.id,
          member_users: [
            build(:custom_group_member_user, user_id: insert(:user).id, position: 1)
          ]
        )

      assert {:ok, %CustomGroup{}} = CustomGroups.delete_custom_group(custom_group)
      assert_raise Ecto.NoResultsError, fn -> CustomGroups.get_custom_group!(custom_group.id) end
    end

    test "change_custom_group/1 returns a custom_group changeset", %{user: user} do
      custom_group = insert(:custom_group, user_id: user.id)
      assert %Ecto.Changeset{} = CustomGroups.change_custom_group(custom_group)
    end
  end

  describe "custom_group_member_users" do
    setup %{user: user} do
      custom_group = insert(:custom_group, user: user)
      %{custom_group: custom_group}
    end

    test "list_member_users with page params", %{
      custom_group: custom_group,
      user: user
    } do
      user_2 = insert(:user) |> with_user_profile()
      insert(:custom_group_member_user, custom_group: custom_group, user: user_2)

      %{entries: [entry]} = CustomGroups.list_member_users(custom_group, %{page: 1, page_size: 6})
      assert entry.user_id == user_2.id
      assert entry.user.id
      assert entry.user.user_profile.id

      custom_group_2 = insert(:custom_group, user: user)

      assert %{entries: []} =
               CustomGroups.list_member_users(custom_group_2, %{page: 1, page_size: 6})
    end
  end
end
