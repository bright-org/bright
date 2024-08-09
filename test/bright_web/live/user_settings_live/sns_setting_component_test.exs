defmodule BrightWeb.UserSettingsLive.SnsSettingComponentTest do
  use BrightWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "SNS連携" do
    setup [:register_and_log_in_user]

    test "shows sns page when no linked sns", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "SNS連携") |> render_click()

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_1 a[href="/auth/google"]},
               "Googleと連携する"
             )

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_2 a[href="/auth/github"]},
               "GitHubと連携する"
             )

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_3 a[href="#"]},
               "Facebookと連携する"
             )

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_4 a[href="#"]},
               "Xと連携する"
             )
    end

    test "clicks 「Googleと連携する」", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "SNS連携") |> render_click()

      lv
      |> element(
        "#user_settings_sns_unlinked_provider_1 a",
        "Googleと連携する"
      )
      |> render_click()
      |> follow_redirect(conn, ~p"/auth/google")
    end

    test "clicks 「GitHubと連携する」", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "SNS連携") |> render_click()

      lv
      |> element(
        "#user_settings_sns_unlinked_provider_2 a",
        "GitHubと連携する"
      )
      |> render_click()
      |> follow_redirect(conn, ~p"/auth/github")
    end

    test "shows sns page when linked only google", %{conn: conn, user: user} do
      insert(:user_social_auth_for_google, user: user, display_name: "dummy@example.com")

      {:ok, lv, _html} = live(conn, ~p"/mypage")

      lv |> element("a", "SNS連携") |> render_click()

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_2 a[href="/auth/github"]},
               "GitHubと連携する"
             )

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_3 a[href="#"]},
               "Facebookと連携する"
             )

      assert lv
             |> has_element?(
               ~s{#user_settings_sns_unlinked_provider_4 a[href="#"]},
               "Xと連携する"
             )

      el =
        lv
        |> element(
          ~s{#user_settings_sns_linked_provider a[href="/auth/google"]},
          "Googleと連携解除する"
        )

      assert el |> render() =~ ~s{data-method="delete"}

      assert lv |> has_element?("#user_settings_sns_linked_provider", "dummy@example.comで連携中")

      el |> render_click() |> follow_redirect(conn, ~p"/auth/google")
    end
  end
end
