defmodule BrightWeb.SkillPanelLive.SkillEvidenceComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest
  import Bright.Factory

  alias Bright.SkillEvidences.SkillEvidencePost

  defp setup_skills(%{user: user}) do
    # エビデンスのため最小限
    skill_panel = insert(:skill_panel)
    insert(:user_skill_panel, user: user, skill_panel: skill_panel)
    skill_class = insert(:skill_class, skill_panel: skill_panel, class: 1)
    skill_unit = insert(:skill_unit)

    _skill_class_unit =
      insert(:skill_class_unit, skill_class: skill_class, skill_unit: skill_unit, position: 1)

    [%{skills: [skill]}] = insert_skill_categories_and_skills(skill_unit, [1])

    %{
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill: skill
    }
  end

  defp open_modal(lv) do
    lv
    |> element("#skill-1 .link-evidence")
    |> render_click()
  end

  # supportフォルダからnamesのファイルをアップロード操作
  defp upload_image(live, names) do
    files =
      Enum.map(names, fn name ->
        %{
          name: name,
          content: Path.join([test_support_dir(), "images", name]) |> File.read!()
        }
      end)

    file_input(live, "#skill_evidence_post-form", :image, files)
  end

  describe "Shows modal" do
    setup [:register_and_log_in_user, :setup_skills]

    test "shows modal case: skill_score NOT existing", %{
      conn: conn,
      skill_panel: skill_panel,
      skill: skill
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert_patch(lv, ~p"/panels/#{skill_panel}/skills/#{skill}/evidences?class=1")
      assert render(lv) =~ skill.name
    end

    test "shows modal case: skill_score existing", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel,
      skill: skill
    } do
      insert(:skill_score, user: user, skill: skill, score: :high)
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert_patch(lv, ~p"/panels/#{skill_panel}/skills/#{skill}/evidences?class=1")
      assert render(lv) =~ skill.name
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

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert render(lv) =~ skill_evidence_post.content
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

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert has_element?(
               lv,
               ~s(#skill_evidence_posts-#{skill_evidence_post.id}),
               "some content by others"
             )

      # 所有者は削除可能
      assert has_element?(
               lv,
               ~s(#skill_evidence_posts-#{skill_evidence_post.id} [phx-click="delete"])
             )
    end
  end

  # 投稿内容
  describe "Posts message" do
    setup [:register_and_log_in_user, :setup_skills]

    test "creates post", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input"})
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts", "input")

      # 永続化確認
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)
      assert has_element?(lv, "#skill_evidence_posts", "input")
    end

    test "deletes post", %{
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
          content: "input"
        )

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert has_element?(lv, "#skill_evidence_posts", "input")

      lv
      |> element(~s([phx-click="delete"][phx-value-id="#{skill_evidence_post.id}"]))
      |> render_click()

      refute has_element?(lv, "#skill_evidence_posts", "input")

      # 永続化確認
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)
      refute has_element?(lv, "#skill_evidence_posts", "input")
    end

    test "validates post message", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      assert lv
             |> form("#skill_evidence_post-form", skill_evidence_post: %{content: ""})
             |> render_submit() =~ "入力してください"
    end
  end

  # 投稿画像
  describe "Uploads image" do
    setup [:register_and_log_in_user, :setup_skills]

    test "uploads image", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      %{entries: [%{"ref" => ref}]} = image = upload_image(lv, ~w(sample.png))
      render_upload(image, "sample.png")
      assert has_element?(lv, ~s(img[data-phx-entry-ref="#{ref}"]))

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input"})
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts .evidence-image img")

      # 永続化確認
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)
      assert has_element?(lv, "#skill_evidence_posts .evidence-image img")
    end

    test "uploads some images", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      image = upload_image(lv, ~w(sample.png sample.jpg))
      render_upload(image, "sample.png")
      render_upload(image, "sample.jpg")

      # # TODO: 複数ファイルでこける。要対応
      # lv
      # |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input"})
      # |> render_submit()
      #
      # {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      # open_modal(lv)
      # assert has_element?(lv, "#skill_evidence_posts .evidence-image img")
    end

    test "deletes image in preview", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      %{entries: [%{"ref" => ref}]} = image = upload_image(lv, ~w(sample.png))
      render_upload(image, "sample.png")
      assert has_element?(lv, ~s(img[data-phx-entry-ref="#{ref}"]))

      lv
      |> element(~s(button[phx-click="cancel_upload"][phx-value-ref="#{ref}"]))
      |> render_click()

      refute has_element?(lv, ~s(img[data-phx-entry-ref="#{ref}"]))
    end

    test "deletes image with post", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")

      # アップロード
      open_modal(lv)
      image = upload_image(lv, ~w(sample.png))
      render_upload(image, "sample.png")

      lv
      |> form("#skill_evidence_post-form", skill_evidence_post: %{content: "input"})
      |> render_submit()

      skill_evidence_post = Bright.Repo.get_by!(SkillEvidencePost, user_id: user.id)
      [storage_path] = skill_evidence_post.image_paths
      assert {:ok, _} = Bright.Utils.GoogleCloud.Storage.get(storage_path)

      # 削除
      lv
      |> element(~s([phx-click="delete"][phx-value-id="#{skill_evidence_post.id}"]))
      |> render_click()

      refute Bright.Repo.get(SkillEvidencePost, skill_evidence_post.id)
      assert {:error, _} = Bright.Utils.GoogleCloud.Storage.get(storage_path)
    end

    test "validates max entries: 4", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      names = ~w(sample.png sample.jpg sample.jpeg sample_2.png sample_2.jpg)
      image = upload_image(lv, names)
      Enum.each(names, &render_upload(image, &1))

      assert has_element?(lv, "#skill_evidence_post-form .text-error", "アップロードするファイルが多すぎます")

      # 以下、一度1つ消して再度アップロード
      %{entries: [%{"ref" => ref} | _]} = image

      lv
      |> element(~s(button[phx-click="cancel_upload"][phx-value-ref="#{ref}"]))
      |> render_click()

      refute has_element?(lv, "#skill_evidence_post-form .text-error", "アップロードするファイルが多すぎます")

      image_added = upload_image(lv, ["sample.png"])
      render_upload(image_added, "sample.png")
      assert has_element?(lv, "#skill_evidence_post-form .text-error", "アップロードするファイルが多すぎます")
    end

    test "validates max file size", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      file_input(lv, "#skill_evidence_post-form", :image, [
        %{
          name: "sample.png",
          content: Path.join([test_support_dir(), "images", "6_000_000byte.png"]) |> File.read!()
        }
      ])
      |> render_upload("sample.png")

      # validateで処理をしているため手動実行
      lv
      |> element("#skill_evidence_post-form")
      |> render_change(%{"skill_evidence_post" => %{}})

      assert has_element?(lv, "#skill_evidence_post-form .text-error", "ファイルサイズが大きすぎます")
    end

    test "validates invalid format: gif, svg", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      ~w(sample.gif sample.svg)
      |> Enum.each(fn name ->
        image = upload_image(lv, [name])
        render_upload(image, name)

        # validateで処理をしているため手動実行
        lv
        |> element("#skill_evidence_post-form")
        |> render_change(%{"skill_evidence_post" => %{}})

        assert has_element?(lv, "#skill_evidence_post-form .text-error", "アップロードできない拡張子です")
      end)
    end
  end

  # ヘルプ
  describe "Help" do
    alias Bright.Notifications.NotificationEvidence

    setup [:register_and_log_in_user, :setup_skills]

    test "submit with help", %{
      conn: conn,
      skill_panel: skill_panel
    } do
      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      lv
      |> form("#skill_evidence_post-form",
        skill_evidence_post: %{content: "input with help"},
        help: "on"
      )
      |> render_submit()

      assert has_element?(lv, "#skill_evidence_posts", "このメモでヘルプを出しました")
    end

    test "creates help notification", %{
      conn: conn,
      user: user,
      skill_panel: skill_panel
    } do
      team = insert(:team)
      user_2 = insert(:user) |> with_user_profile()
      insert(:team_member_users, team: team, user: user)
      insert(:team_member_users, team: team, user: user_2)

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}?class=1")
      open_modal(lv)

      lv
      |> form("#skill_evidence_post-form",
        skill_evidence_post: %{content: "input with help"},
        help: "on"
      )
      |> render_submit()

      assert Bright.Repo.get_by(NotificationEvidence, from_user_id: user.id, to_user_id: user_2.id)
    end
  end

  # アクセス制限など
  describe "Access" do
    setup [:register_and_log_in_user, :setup_skills]

    test "cannot post to anonymous user's evidence", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill: skill
    } do
      user_2 = insert(:user)
      encrypted_name = BrightWeb.DisplayUserHelper.encrypt_user_name(user_2)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:skill_class_score, user: user_2, skill_class: skill_class)
      insert(:skill_evidence, user: user_2, skill: skill)

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}/anon/#{encrypted_name}")
      open_modal(lv)

      assert has_element?(lv, "#skill-evidence-modal-content")
      refute has_element?(lv, "#skill_evidence_post-form")
    end

    test "cannot delete other users post", %{
      conn: conn,
      skill_panel: skill_panel,
      skill_class: skill_class,
      skill: skill
    } do
      user_2 = insert(:user) |> with_user_profile()
      encrypted_name = BrightWeb.DisplayUserHelper.encrypt_user_name(user_2)
      insert(:user_skill_panel, user: user_2, skill_panel: skill_panel)
      insert(:skill_class_score, user: user_2, skill_class: skill_class)
      skill_evidence = insert(:skill_evidence, user: user_2, skill: skill)

      skill_evidence_post =
        insert(:skill_evidence_post, user: user_2, skill_evidence: skill_evidence)

      {:ok, lv, _html} = live(conn, ~p"/panels/#{skill_panel}/anon/#{encrypted_name}")
      open_modal(lv)

      assert has_element?(
               lv,
               "#skill_evidence_posts-#{skill_evidence_post.id}",
               skill_evidence_post.content
             )

      refute has_element?(
               lv,
               ~s(#skill_evidence_posts-#{skill_evidence_post.id} [phx-click="delete"])
             )
    end
  end
end
