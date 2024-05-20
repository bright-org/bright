defmodule BrightWeb.NotificationLive.SkillUpdateTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  setup [:register_and_log_in_user]

  describe "render page" do
    test "renders page", %{conn: conn, user: user} do
      {:ok, _lv, html} = live(conn, ~p"/notifications/skill_updates")

      assert html =~ "スキルアップの通知"
      assert html =~ "スキルアップの通知はありません"

      insert(:notification_skill_update, to_user: user)

      {:ok, _lv, html} = live(conn, ~p"/notifications/skill_updates")

      refute html =~ "スキルアップの通知はありません"
    end
  end

  describe "render paginated notifications" do
    test "renders paginated notifications", %{conn: conn, user: to_user} do
      notification_skill_updates =
        insert_list(11, :notification_skill_update, to_user: to_user)
        |> Enum.sort_by(& &1.id, :desc)

      {:ok, lv, _html} = live(conn, ~p"/notifications/skill_updates")

      notification_message_10 = notification_skill_updates |> Enum.at(9) |> Map.get(:message)
      notification_message_11 = notification_skill_updates |> Enum.at(10) |> Map.get(:message)

      assert lv
             |> has_element?("#notification_skill_update_container span", notification_message_10)

      refute lv
             |> has_element?("#notification_skill_update_container span", notification_message_11)

      lv |> element(~s{button[phx-click="next_button_click"]}) |> render_click()

      refute lv
             |> has_element?("#notification_skill_update_container span", notification_message_10)

      assert lv
             |> has_element?("#notification_skill_update_container span", notification_message_11)

      lv |> element(~s{button[phx-click="previous_button_click"]}) |> render_click()

      assert lv
             |> has_element?("#notification_skill_update_container span", notification_message_10)

      refute lv
             |> has_element?("#notification_skill_update_container span", notification_message_11)
    end
  end

  describe "notification clicked" do
    setup do
      # スキル構造のデータ準備
      skill_panel = insert(:skill_panel)
      skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
      %{skill_panel: skill_panel, skill_class: skill_class}
    end

    setup %{skill_panel: skill_panel, skill_class: skill_class} do
      # 通知元（スキルアップを達成した）ユーザーのデータ準備
      user_2 = insert(:user) |> with_user_profile()
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:skill_class_score, user: user_2, skill_class: skill_class, level: :normal)

      %{user_2: user_2}
    end

    test "redirects /panels page", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      insert(
        :notification_skill_update,
        to_user: user,
        from_user: user_2,
        message: "タイトル",
        url: "/panels/#{skill_panel.id}/#{user_2.name}"
      )

      # user/user_2の関係を作っている
      relate_user_and_supporter(user, user_2)

      {:ok, lv, _html} = live(conn, ~p"/notifications/skill_updates")
      result = lv |> element(~s{div[phx-click="click"]}, "タイトル") |> render_click()

      assert {:ok, _, _} =
               follow_redirect(result, conn, "/panels/#{skill_panel.id}/#{user_2.name}")
    end

    test "raises error if the user is unrelated", %{
      conn: conn,
      user: user,
      user_2: user_2,
      skill_panel: skill_panel
    } do
      # 通知を作っているが、user/user_2の関係を作っていない
      insert(
        :notification_skill_update,
        to_user: user,
        from_user: user_2,
        message: "タイトル",
        url: "/panels/#{skill_panel.id}/#{user_2.name}"
      )

      {:ok, lv, _html} = live(conn, ~p"/notifications/skill_updates")
      result = lv |> element(~s{div[phx-click="click"]}, "タイトル") |> render_click()

      assert_raise Bright.Exceptions.ForbiddenResourceError, fn ->
        follow_redirect(result, conn, "/panels/#{skill_panel.id}/#{user_2.name}")
      end
    end
  end
end
