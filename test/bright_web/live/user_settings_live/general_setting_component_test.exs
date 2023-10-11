defmodule BrightWeb.UserSettingsLive.GeneralSettingComponentTest do
  use BrightWeb.ConnCase, async: true

  alias Bright.Repo
  alias Bright.Accounts.User
  alias Bright.UserProfiles
  alias Bright.UserProfiles.UserProfile
  import Phoenix.LiveViewTest
  import Bright.Factory

  setup [:register_and_log_in_user]

  describe "一般" do
    test "shows each sections", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      assert lv |> has_element?("#general_setting_form", "ハンドル名")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[name]"][value="#{user.name}"]}
             )

      assert lv |> has_element?("#general_setting_form", "称号")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[user_profile][title]"][value="#{user.user_profile.title}"]}
             )

      assert lv |> has_element?("#general_setting_form", "GitHub")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[user_profile][github_url]"][value="#{user.user_profile.github_url}"]}
             )

      assert lv |> has_element?("#general_setting_form", "Twitter")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[user_profile][github_url]"][value="#{user.user_profile.github_url}"]}
             )

      assert lv |> has_element?("#general_setting_form", "Facebook")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[user_profile][facebook_url]"][value="#{user.user_profile.facebook_url}"]}
             )

      assert lv |> has_element?("#general_setting_form", "自己紹介")

      assert lv
             |> has_element?(
               ~s{#general_setting_form input[name="user[user_profile][twitter_url]"][value="#{user.user_profile.twitter_url}"]}
             )

      assert lv |> has_element?("#general_setting_form", "アイコン")

      assert lv
             |> has_element?(
               ~s{#general_setting_form img[src="#{UserProfiles.icon_url(user.user_profile.icon_file_path)}"]}
             )
    end

    test "shows default icon when icon_file_path is nil", %{conn: conn} do
      Repo.update_all(UserProfile, set: [icon_file_path: nil])

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      assert lv |> has_element?("#general_setting_form .bg-bgAddAvatar")
    end

    test "submits general setting form without uploading icon", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      %{name: new_name} = params_for(:user)

      user_profile_attrs =
        params_for(:user_profile)
        |> Map.take([:title, :github_url, :facebook_url, :twitter_url, :detail])

      lv
      |> form("#general_setting_form",
        user: %{name: new_name, user_profile: user_profile_attrs}
      )
      |> render_submit()

      # NOTE: フラッシュメッセージが出るまで 600ms 程度待つ
      Process.sleep(600)
      assert lv |> has_element?("#modal_flash", "保存しました")

      assert %User{name: ^new_name} = Repo.get(User, user.id)

      assert Repo.get(UserProfile, user.user_profile.id)
             |> Map.take([
               :title,
               :detail,
               :twitter_url,
               :facebook_url,
               :github_url
             ]) == user_profile_attrs
    end

    test "submits general setting form with uploading icon", %{conn: conn, user: user} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      %{name: new_name} = params_for(:user)

      file_input(lv, "#general_setting_form", :icon, [
        %{
          name: "sample.png",
          content: Path.join([test_support_dir(), "images", "sample.png"]) |> File.read!()
        }
      ])
      |> render_upload("sample.png")

      user_profile_attrs =
        params_for(:user_profile)
        |> Map.take([:title, :github_url, :facebook_url, :twitter_url, :detail])

      lv
      |> form("#general_setting_form",
        user: %{name: new_name, user_profile: user_profile_attrs}
      )
      |> render_submit()

      # NOTE: フラッシュメッセージが出るまで 600ms 程度待つ
      Process.sleep(600)
      assert lv |> has_element?("#modal_flash", "保存しました")

      assert %User{name: ^new_name} = Repo.get(User, user.id)

      user_profile = Repo.get(UserProfile, user.user_profile.id)

      assert user_profile
             |> Map.take([
               :title,
               :detail,
               :twitter_url,
               :facebook_url,
               :github_url
             ]) == user_profile_attrs

      assert {:ok, _} = Bright.TestStorage.get(user_profile.icon_file_path)
    end

    test "validates general setting form without icon", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      new_name = String.duplicate("a", 31)

      user_profile_attrs = %{
        title: String.duplicate("a", 31),
        detail: String.duplicate("a", 256),
        twitter_url: String.duplicate("a", 256),
        facebook_url: String.duplicate("a", 256),
        github_url: String.duplicate("a", 256)
      }

      lv
      |> form("#general_setting_form",
        user: %{name: new_name, user_profile: user_profile_attrs}
      )
      |> render_change()

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[name]"] .text-error},
               "30文字以内で入力してください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][title]"] .text-error},
               "30文字以内で入力してください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][detail]"] .text-error},
               "255文字以内で入力してください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][github_url]"] .text-error},
               "https://github.com/ から始めてください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][github_url]"] .text-error},
               "255文字以内で入力してください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][twitter_url]"] .text-error},
               "https://twitter.com/ または https://x.com/ から始めてください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][twitter_url]"] .text-error},
               "255文字以内で入力してください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][facebook_url]"] .text-error},
               "https://www.facebook.com/ から始めてください"
             )

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[user_profile][facebook_url]"] .text-error},
               "255文字以内で入力してください"
             )
    end

    test "validates user name uniqueness when submitting", %{conn: conn, user: user} do
      other_user = insert(:user)

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      lv
      |> form("#general_setting_form",
        user: %{name: other_user.name}
      )
      |> render_submit()

      assert lv
             |> has_element?(
               ~s{#general_setting_form div[phx-feedback-for="user[name]"] .text-error},
               "すでに使用されています"
             )

      refute Repo.get(User, user.id).name == other_user.name
    end

    test "validates icon file size is too large", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      file_input(lv, "#general_setting_form", :icon, [
        %{
          name: "sample.png",
          content: Path.join([test_support_dir(), "images", "sample.png"]) |> File.read!(),
          size: 3_000_000
        }
      ])
      |> render_upload("sample.svg")

      assert lv |> has_element?("#general_setting_form .text-error", "ファイルサイズが大きすぎます")
    end

    test "validates icon file format", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      file_input(lv, "#general_setting_form", :icon, [
        %{
          name: "sample.jpg",
          content: Path.join([test_support_dir(), "images", "sample.jpg"]) |> File.read!(),
          size: 1_000_000
        }
      ])
      |> render_upload("sample.jpg")

      refute lv |> has_element?("#general_setting_form .text-error")

      file_input(lv, "#general_setting_form", :icon, [
        %{
          name: "sample.jpeg",
          content: Path.join([test_support_dir(), "images", "sample.jpeg"]) |> File.read!(),
          size: 1_000_000
        }
      ])
      |> render_upload("sample.jpeg")

      refute lv |> has_element?("#general_setting_form .text-error")

      file_input(lv, "#general_setting_form", :icon, [
        %{
          name: "sample.svg",
          content: Path.join([test_support_dir(), "images", "sample.svg"]) |> File.read!(),
          size: 1_000_000
        }
      ])
      |> render_upload("sample.svg")

      assert lv |> has_element?("#general_setting_form .text-error", "アップロードできない拡張子です")
    end

    test "validates icon file must upload only one entry", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "一般") |> render_click()

      icon =
        file_input(lv, "#general_setting_form", :icon, [
          %{
            name: "sample.png",
            content: Path.join([test_support_dir(), "images", "sample.png"]) |> File.read!(),
            size: 1_000_000
          },
          %{
            name: "sample.jpg",
            content: Path.join([test_support_dir(), "images", "sample.jpg"]) |> File.read!(),
            size: 1_000_000
          }
        ])

      render_upload(icon, "sample.png")
      render_upload(icon, "sample.jpg")

      assert lv |> has_element?("#general_setting_form .text-error", "アップロードするファイルが多すぎます")
    end
  end
end
