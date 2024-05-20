defmodule BrightWeb.NotificationLive.EvidenceTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  setup [:register_and_log_in_user]

  describe "render page" do
    test "renders page", %{conn: conn, user: user} do
      {:ok, _lv, html} = live(conn, ~p"/notifications/evidences")

      assert html =~ "学習メモの通知"
      assert html =~ "学習メモの通知はありません"

      insert(:notification_evidence, to_user: user)

      {:ok, _lv, html} = live(conn, ~p"/notifications/evidences")

      refute html =~ "学習メモの通知はありません"
    end
  end

  describe "render paginated notifications" do
    test "renders paginated notifications", %{conn: conn, user: to_user} do
      notification_evidences =
        insert_list(11, :notification_evidence, to_user: to_user) |> Enum.sort_by(& &1.id, :desc)

      {:ok, lv, _html} = live(conn, ~p"/notifications/evidences")

      notification_message_10 = notification_evidences |> Enum.at(9) |> Map.get(:message)
      notification_message_11 = notification_evidences |> Enum.at(10) |> Map.get(:message)

      assert lv |> has_element?("#notification_evidence_container span", notification_message_10)
      refute lv |> has_element?("#notification_evidence_container span", notification_message_11)

      lv |> element(~s{button[phx-click="next_button_click"]}) |> render_click()

      refute lv |> has_element?("#notification_evidence_container span", notification_message_10)
      assert lv |> has_element?("#notification_evidence_container span", notification_message_11)

      lv |> element(~s{button[phx-click="previous_button_click"]}) |> render_click()

      assert lv |> has_element?("#notification_evidence_container span", notification_message_10)
      refute lv |> has_element?("#notification_evidence_container span", notification_message_11)
    end
  end

  describe "notification modal" do
    setup do
      skill_unit = insert(:skill_unit)
      skill_category = insert(:skill_category, skill_unit: skill_unit)
      skill = insert(:skill, skill_category: skill_category)
      %{skill: skill}
    end

    setup %{skill: skill, user: user} do
      user_2 = insert(:user) |> with_user_profile()
      team = insert(:team)
      insert(:team_member_users, team: team, user: user_2)
      insert(:team_member_users, team: team, user: user)

      skill_evidence = insert(:skill_evidence, user: user_2, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post, user: user_2, skill_evidence: skill_evidence, content: "HELP")

      %{
        user_2: user_2,
        skill_evidence: skill_evidence,
        skill_evidence_post: skill_evidence_post
      }
    end

    test "shows modal", %{
      conn: conn,
      user: user,
      skill_evidence: skill_evidence,
      skill_evidence_post: skill_evidence_post
    } do
      insert(:notification_evidence,
        to_user: user,
        message: "タイトル",
        url: "/notifications/evidences/#{skill_evidence.id}"
      )

      {:ok, lv, _html} = live(conn, ~p"/notifications/evidences")

      refute has_element?(lv, "#notification_evidence_modal")

      lv |> element(~s{div[phx-click="click"]}, "タイトル") |> render_click()

      assert has_element?(lv, "#notification_evidence_modal")
      assert has_element?(lv, "#skill_evidence_posts-#{skill_evidence_post.id}")
    end

    test "creates skill_evidence_post", %{
      conn: conn,
      user: user,
      skill_evidence: skill_evidence
    } do
      insert(:notification_evidence,
        to_user: user,
        message: "タイトル",
        url: "/notifications/evidences/#{skill_evidence.id}"
      )

      {:ok, lv, _html} = live(conn, ~p"/notifications/evidences")
      lv |> element(~s{div[phx-click="click"]}, "タイトル") |> render_click()

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input"})
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts", "input")
    end

    test "shows modal denied, if user is no longer a team member", %{
      conn: conn,
      user: user,
      skill_evidence: skill_evidence
    } do
      insert(:notification_evidence,
        to_user: user,
        message: "タイトル",
        url: "/notifications/evidences/#{skill_evidence.id}"
      )

      Bright.Repo.delete_all(Ecto.assoc(user, :team_member_users))

      {:ok, lv, _html} = live(conn, ~p"/notifications/evidences")
      lv |> element(~s{div[phx-click="click"]}, "タイトル") |> render_click()

      assert has_element?(lv, "#notification_evidence_modal_show_denied")
    end
  end
end
