defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  defp setup_skills(%{user: user}) do
    # エビデンスのため最小限
    skill_panel = insert(:skill_panel)
    insert(:user_skill_panel, user: user, skill_panel: skill_panel)
    skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
    skill_unit = insert(:skill_unit)
    _skill_class_unit = insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit, position: 1)
    [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

    %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill: skill
    }
  end

  defp open_modal(show_live) do
    show_live
    |> element("#skill-1 .link-evidence")
    |> render_click()
  end

  describe "Shows modal" do
    setup [:register_and_log_in_user, :setup_skills]

    test "shows modal case: skill_score NOT existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill: skill
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill}/evidences?class=1")
      assert render(show_live) =~ skill.name
    end

    test "shows modal case: skill_score existing", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill: skill
    } do
      insert(:skill_score, user: user, skill: skill, score: :high)
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert_patch(show_live, ~p"/panels/#{skill_panel}/skills/#{skill}/evidences?class=1")
      assert render(show_live) =~ skill.name
    end

    test "shows posts", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill: skill
    } do
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post,
          user: user,
          skill_evidence: skill_evidence,
          content: "some content"
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert render(show_live) =~ skill_evidence_post.content
    end

    test "shows others posts", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill: skill
    } do
      user_2 = insert(:user) |> with_user_profile()
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post,
          user: user_2,
          skill_evidence: skill_evidence,
          content: "some content by others"
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert render(show_live) =~ skill_evidence_post.content
    end
  end

  describe "Posts message" do
    setup [:register_and_log_in_user, :setup_skills]

    test "creates post", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      show_live
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input 1"})
      |> render_submit()

      assert has_element?(show_live, "#skill_evidence_posts", "input 1")

      # 永続化確認
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)
      assert has_element?(show_live, "#skill_evidence_posts", "input 1")
    end

    test "removes post", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill: skill
    } do
      skill_evidence = insert(:skill_evidence, user: user, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post,
          user: user,
          skill_evidence: skill_evidence,
          content: "input 1"
        )

      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert has_element?(show_live, "#skill_evidence_posts", "input 1")

      show_live
      |> element(~s([phx-click="delete"][phx-value-id="#{skill_evidence_post.id}"]))
      |> render_click()

      refute has_element?(show_live, "#skill_evidence_posts", "input 1")

      # 永続化確認
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)
      refute has_element?(show_live, "#skill_evidence_posts", "input 1")
    end

    test "validates post message", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, show_live, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(show_live)

      assert show_live
             |> form("#skill_evidence_post-form", skill_evidence_post: %{content: ""})
             |> render_submit() =~ "入力してください"
    end
  end

  describe "Uploads image" do
    test "uploads image" do
      # TODO
    end

    test "removes image in preview" do
      # TODO
    end

    test "removes image with post" do
      # TODO
    end

    test "validates max entries" do
      # TODO
    end

    test "validates max file size" do
      # TODO
    end

    test "validates format" do
      # TODO
    end
  end
end
